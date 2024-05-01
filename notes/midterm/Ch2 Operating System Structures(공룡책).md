# Ch2. Operating System Structures(공룡책)

## 2.1 Operating System Services

- User Interface
    - GUI
    - CLI
- Program execution
    - 프로그램을 메모리에 load해 실행하고, 정상적이든 비정상적이든 실행을 끝내야 함
- I/O operation
    - 사용자는 I/O device를 직접 제어할 수 없음
    - 운영체제가 입출력 수행의 수단을 제공해야 함
- File system manipulation
    - 파일 생성/삭제
    - 권한 관리
- communication
    - 프로세스끼리 통신
        - 공유 메모리
        - 메시지 전달
    - 컴퓨터끼리 통신
        - 패킷
- error detection
    - CPU, 메모리, 하드웨어, I/O device의 오류 조치
    - 사용자 프로그램의 오류 조치
        - 오버플로우
        - 부적절한 메모리 접근
- resource allocation
    - 다수의 프로세스가 실행될 때, 프로세스들에 적절히 자원을 할당
    - CPU 스케줄링에서 고려해야 할 사항
        - CPU의 속도
        - 반드시 실행해야 할 프로세스들
        - 코어의 개수
    - I/O device 역시 스케줄링의 대상
- logging
- protection and security

## 2.2 User and Operating System Interface

### Command Interpreter

- shell

### Graphical User Interface

## 2.3 System Calls

### Application Programming Interface

- API의 함수들은 개발자를 대신하여 실제 시스템 콜을 호출
    - 시스템 콜은 아키텍쳐마다 다르기에, 호환성을 위하여
    - 시스템 콜은 단순한(Low level) 함수이기에 다루기가 까다로워서
- RTE(실행시간 환경)
    - 컴파일러, 인터프리터 등 프로그램을 실행하는데 필요한 전체 제품군 + 링커, 로더
    - RTE는 **System Call Interface**를 제공
    
    ![Untitled](Ch2%20Operating%20System%20Structures(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20599de2c410784da5988811fe956de0c9/Untitled.png)
    
    - 매개변수 전달
    
    ![Untitled](Ch2%20Operating%20System%20Structures(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20599de2c410784da5988811fe956de0c9/Untitled%201.png)
    

### Types of System Calls

- Process Control
    - end, abort
    - load, execute
    - 생성, 삭제
    - 프로세스 속성 획득, 속성 설정
    - wait
    - event wait, signal event
    - memory allocation and free
- File Management
    - create file, delete file
    - open, close
    - reposition
    - 파일 속성 획득 및 설정
- Device management
    - request, release device
    - reposition
    - 장치 속성 획득, 속성 설정
    - attach, detach
- information Maintenance
    - 시간, 날짜 설정/획득
    - 시스템 데이터 설정/획득프로세스, 파일, 장치 속성 획득/설정
- communication
    - communication connection 생성/제거
    - 메시지 송/수신
    - 상태 정보 전달
    - attach, detach
- protection
    - file permission 설정

### Process Control

- 실행 중인 프로그램은 수행을 정상적으로든(end()), 비정상적으로든(abort()) 멈춰야 함
- 비정상적으로 중지하기 위해 시스템 콜이 호출되거나 오류 trap을 유발할 경우, 디버거