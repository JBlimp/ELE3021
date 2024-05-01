# Ch1. Overview(공룡책)

## 1.1 What Operating Systems Do

![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled.png)

### 컴퓨터 시스템의 구성 요소

- 하드웨어: CPU, I/O device
- 응용 프로그램
- 운영체제
- 사용자

### 컴퓨터를 다루는 관점

- User
    - 사용의 용이성이 중요
    - 자원의 이용(하드웨어, 소프트웨어의 자원 관리)는 신경쓰지 않음
- System
    - 운영체제는 하드웨어와 가장 밀접한 프로그램
    - resource allocator
    - control program

### 운영체제의 정의

- 운영체제를 명확히 정의하는 문장은 없음
- 커널 + 시스템 프로그램 + 미들웨어

## 1.2 Computer System Organization

### CPU + I/O device + BUS

![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%201.png)

- 버스는 CPU와 구성요소와 공유 메모리 사이의 액세스를 제공하는 데이터 통로
- 각 I/O device controller마다 장치 드라이버가 존재

### Interrupt

- CPU가 인터럽트되면, 하던 일을 중단하고 즉시 고정된 위치로 실행을 옮김
    - 고정된 위치: 인터럽트 서비스 루틴이 위치한 시작 주소
    - 인터럽트 테이블을 참조하여 인터럽트 고유의 핸들러를 호출
        
        ![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%202.png)
        
- 구현
    - **Interrupt request line**(인터럽트 요청 라인)
        - Interrupt enable register의 bit가 1일 때만(인터럽트가 활성화되었을 때만)
        - 하나의 명령어 실행을 완료할 때마다 CPU는 라인을 감지
        - 신호를 감지하면, 인터럽트 번호를 읽고 그 번호를 테이블의 인덱스로 사용하여 **Interrupt-handler routine**으로 점프
        - 인터럽트 핸들러는
            1. 작업 중 변경될 상태 저장
            2. 인터럽트 원인 확인
            3. 필요한 처리 수행
            4. 상태 복원
            5. return_from_interrupt 호출, 인터럽트 끝
                
                ![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%203.png)
                
- 인터럽트 단계 정리
    1. I/O device controller가 인터럽트 **발생(raise)**시킴
    2. CPU는 인터럽트를 **포착(catch)**
    3. 인터럽트 핸들러로 **점프(dispatch)**
    4. 핸들러는 인터럽트를 처리하여 인터럽트를 **지움(clear)**
- 인터럽트 처리 기능 요구사항
    - 중요한 작업 중에는 인터럽트 처리를 연기할 수 있어야 함
    - 적절한 인터럽트 핸들러로 디스패치 할 방법이 필요함
    - 인터럽트의 우선순위 구분, 적절한 긴급도로 대응할 수 있어야 함
    - CPU + Interrupt controller HW가 기능을 제공

### 저장장치 구조

- 메모리 계층 구조
    
    ![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%204.png)
    
    - 레지스터
    - 캐시
    - 메인 메모리
    - 비휘발성 메모리
    - 하드 디스크 드라이브
- 컴퓨터의 전원이 켜지면
    - 가장 먼저 실행되는 프로그램은 부트스트랩
    - ROM, 펌웨어에 부트스트랩을 저장
    - 부트스트랩은 OS를 메모리에 load

### 입출력 구조

- DMA
    
    ![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%205.png)
    
    - CPU의 개입 없이 메모리와 I/O device의 버퍼간 데이터를 교환
    - 블럭 단위로 인터럽트 발생

## 1.3 Computer System Architecture

### Single Processor Systems

- 코어
    - 명령을 실행하고 로컬로 데이터를 저장하기 위한 레지스터를 포함하는 구성 요소
- 단일코어 프로세서 시스템은 이 범용 CPU가 하나

### Multiprocessor Systems

- multicore
    - 여러 코어를 포함하는 CPU 사용
- multiprocessor
    - 여러 프로세서를 포함
- 코어끼리 버스, clock, 메모리, device를 공유
- Cache 구조
    - 각 코어마다 L1 cache
    - 코어들이 공유하는 CPU 내의 L2 cache
    - CPU 외부의 L3 cache

## 1.4 OS Operations

- OS가 작동하기 위해
    - 전원이 켜지면 부트스트랩 프로그램이 OS의 커널을 메모리에 load
- OS 이벤트
    - 인터럽트
    - 트랩
    - 시스템 콜

### multiprogramming and multitasking

- 프로세스
    - 멀티프로그래밍 환경에서 실행 중인 프로그램
    - CPU가 항상 한 개는 실행할 수 있도록 프로그램을 구성
- 멀티태스킹
    - 멀티프로그래밍의 논리적 확장
    - CPU 스케줄링을 활용하여 멀티프로그래밍을 일반화
    - 메모리가 부족하기에 virtual memory를 이용

### Dual-Mode and Multimode Operation

- User mode와 Kernal mode
    - mode bit을 이용해 모드를 구분
- 부팅 시 커널 모드로 실행됨. 운영체제가 load된 후 유저 모드에서 프로그램 시작.
- trap이나 interrupt 발생시 HW는 user mode에서 kernal mode로 전환(mode bit을 0으로)
    
    ![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%206.png)
    
- Privileged instruction은 커널 모드에서만 실행 가능
    - 유저 모드에서 실행시 운영체제로 트랩
    - 커널 모드로 전환하는 명령어, I/O 제어, 타이머 관리, 인터럽트 관리 등
- **System call**
    - user program이 커널의 권한이 필요한 작업을 수행해야 할 때 호출
    - 자신을 대신하여 운영체제가 작업을 수행하도록

### Timer

- 타이머 역시 인터럽트를 발생시키는 Device
- 일정한 시간마다 인터럽트를 발생시킴

## 1.5 Resource Management

### Process Management

- 프로세스
    - 실행중인 프로그램을 의미
- 프로세스는 작업을 수행하기 위해 CPU 시간, 메모리, 파일, I/O 디바이스 등 많은 자원을 필요로 함
- 프로그램 vs 프로세스
    - 프로그램은 디스크에 저장된 파일의 내용과 같이 수동적 존재
    - 프로세스는 program counter를 가진 능동적 존재
- 운영체제는 다음의 작업을 수행해야 함
    - user process, system process 생성과 삭제
    - CPU에 프로세스 ,스레드 스케줄링
    - 프로세스 일시중지, 재실행
    - 프로세스 동기화
    - 프로세스 communication

### Memory Management

- CPU가 Instruction을 실행하기 위해서, Instruction은 반드시 메모리에 올라와야 함
- 메인 메모리는 CPU가 직접 주소를 지정할 수 있고, 직접 접근할 수 있음
- 프로그램이 수행되기 위해서는 instruction이 절대 주소로 매핑되고 메모리에 load 되어야 함
- 실행할 프로그램이 모두 메모리에 load되면 메모리가 부족할수도, OS는 이를 관리해야 함
- 운영체제가 수행해야 할 작업
    - 메모리의 어느 부분이 사용중인지, 어느 프로세스가 사용중인지 추적
    - 메모리 공간 allocation, deallocation
    - 어떤 프로세스를 메모리에 load하고 제거할지 결정

### File-System Management

- 2차 저장장치(ssd, hdd등)과 그것을 제어하는 장치를 관리함으로써 파일의 추상적인 개념을 구현
- 운영체제가 수행해야 할 작업
    - 파일 생성, 제거
    - 디렉토리 생성, 제거
    - 파일, 디렉토리 조작을 위한 primitive 제공
    - 파일을 보조 저장장치로 맵핑
    - non-volatile storage에 파일 백업

### Cache Management

- 메모리보다 더 빠르고 용량은 더 작은 저장장치
- 캐시↔레지스터 데이터 전송은 HW적으로 이루어짐
- 캐시↔메모리 데이터 전송은 운영체제가 관리

![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%207.png)

- Cache Coherence Problem
    - 캐시의 A 값을 수정하면, 메인 메모리의 A값과 캐시의 A값은 다를 것
    - 운영체제는 캐시와 메모리의 값을 최신 상태로 유지해야 함

### I/O System Management

- 사용자에게 I/O Device의 특성을 숨김
- 운영체제가 해야할 일
    - 버퍼링, 캐싱, 스풀링 등 메모리 관리 구성요소
    - general 장치 드라이버 인터페이스
    - 특정 하드웨어 장치들을 위한 드라이버

### 

## 1.6 Security and Protection

- Protection
    - System의 자원에 권한이 없는 자가 접근하는 것을 차단
- Security
    - 보안 기능
    - 사용자를 구분하기 위해
        - UID, GID
        - 임시적인 권한 상승을 지원

## 1.7 Virtualization

![Untitled](Ch1%20Overview(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20b42c396a150b45689d555c026e81e97b/Untitled%208.png)

- 클라우드 컴퓨팅 환경에서 효율적

## 1.8 Distributed System

생략

## 1.9 Kernel Data Structures

### Lists, Stacks, Queues

### Trees

### Hash Functions and Maps

### Bitmaps

## 1.10 Computing Environments

### Traditional Computing

-