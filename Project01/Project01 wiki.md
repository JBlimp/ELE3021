# Project01 wiki

**Project01 WIKI**

2020087801 이준석

- **Design**

1) 새로운 시스템 콜 getgpid()를 구현해야 하므로 getgpid()를 구현 후 커널에 getgpid()를 등록한다.

2) getgpid()는 유저 프로그램에서 사용될 수 있어야 하므로 user.h, usys.S에 getgpid()를 등록한다.

3) getgpid()는 조부모 프로세스의 PID를 반환해야 하므로 우선 부모 프로세스의 PID를 구한 후 그 프로세스의 부모 프로세스 PID를 구하여 반환한다.

- **Implement**

**1) getgpid() 구현**

- syscall.c

getpid 함수를 분석하기 위해 syscall.c 파일에서 getpid를 찾아본 결과 다음과 같은 함수를 찾을 수 있다.

sys_getpid(void) 함수의 위치를 찾기 위해 ‘grep “sys_getpid(void)” *’ 명령어를 사용한 결과 sysproc.c 파일 안에 구현이 되어 있음을 알 수 있다.

- sysproc.c

sys_getpid(void) 함수는 sysproc.c 파일 내부에 구현되어 있다. 여기서 myproc() 객체의 pid를 return 하고 있음을 알 수 있다.

- proc.h

proc.h 파일에 구현된 struct proc의 구조를 보면 parent 성분을 갖고 있음을 알 수 있다. 즉, 이 parent의 parent의 pid를 리턴하면 될 것이다.

- sysproc.c

sysproc.c 파일 내부에 myproc()의 조부모 프로세스의 pid를 리턴하는 함수를 구현한다. 조부모가 존재하지 않는 경우가 있을 수 있으므로 조부모가 NULL인 경우를 확인하는 단계도 추가하였다. 명세에는 따로 나와있지 않지만, 이 경우 -1을 출력하도록 하였다.

NULL은 ‘stddef.h’에 구현되어 있기에 sysproc.c 파일에 stddef.h를 추가로 include하였다.

**2) getgpid() 커널에 등록**

- syscall.h

SYS_getgpid의 시스템 호출 번호를 23으로 매핑한다.

- syscall.c

시스템 호출 구현을 위해 syscall.c에 sys_getgpid(void) 함수를 등록한다.

lab03의 예제와 달리 defs.h에 함수를 등록할 필요는 없는데, 새로운 파일을 만들어 시스템 콜을 추가한 것이 아닌 기존의 syscall.c 파일을 활용했기 때문이다.

**3) getgpid() 유저 라이브러리 등록**

- user.h

유저 프로그램에서 getgpid를 call 할 수 있도록 user.h에 선언을 정의해준다.

- usys.S

usys.S 파일의 .global name에 해당하는 시스템 콜을 정의하기 위해 getgpid 함수를 추가해준다.

**4) 유저 프로그램**

- project01.c

명세대로 학번, pid, gpid를 순서대로 출력한다.

여기서 printf 사용에 유의해야 하는데, stdio.h에 정의되어 있는 printf와 파라미터가 달랐다.

- **Result**
- 실행 방법
1. docker 실행
2. xv6 boot
3. user program ‘project01’ 실행
- **Principle of Operation**
1. user.h, usys.S에서 정의된 getgpid 함수 호출
2. syscall.h, syscall.c에서 정의된 SYS_getgpid의 number를 eax 레지스터에 로드
3. int $T_SYSCALL; 실행
4. 3번 과정은 시스템 콜 인터럽트를 발생시킴, trap.h를 보면 64번 interrup를 발생시킴을 알 수 있다.
5. trap.c에서 struct trapframe의 trapno를 확인하여 syscall()을 호출한다.
6. syscall()에서 매핑된 함수 포인터를 호출한다. defs.h에 sys_getgpid가 선언되어 있다.
7. sysproc.c의 sys_getpid 함수를 실행한다.
8. sys_getpid 함수는 현재 프로세스의 조부모 프로세스 pid를 리턴한다. 만약 조부모 프로세스가 없을시 -1을 리턴한다.
- **Trouble shooting**

**Problem1**

처음에는 lab02대로 새로운 파일 getgpid.c를 만들어 defs.h에 파일을 등록하는 과정을 거치려 했으나 구현을 위해 proc 구조체를 사용해야 하고 include하는 과정이 복잡해졌다.

**Solution1**

sysproc.c에 구현하도록 수정하였다. 시스템 유지 보수의 측면에서도 비슷한 기능을 하는 system call을 같은 위치에 구현하는게 맞다고 판단하였다.

**Problem2**

최초 getgpid를 구현할 때 getpid의 proc 구조체의 구조를 알지 못하고 pid를 이용해 부모 프로세스의 pid를 호출하는 방식을 선택하려 했으나 getpid 함수는 현재 프로세스의 pid만을 리턴할 수 있었다.

**Solution2**

proc 구조체를 살펴본 결과 parent라는 proc의 포인터 성분을 갖고 있음을 확인했다.

**Problem3**

만약 조부모 프로세스가 없을 경우 (현재 프로세스가 root 프로세스의 child process일 경우) 어떻게 처리를 해야 하는지 고민이었다.

**Solution3**

조부모 프로세스가 NULL일 경우 -1을 반환하도록 하였다.