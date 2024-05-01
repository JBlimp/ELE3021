# Ch4. Threads & Concurrency(공룡책)

## 4.1 Overview

### Motivation

![Untitled](Ch4%20Threads%20&%20Concurrency(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%2093064f16b3c34105bd45ba2a9e8628a1/Untitled.png)

- 스레드 구성 요소
    - PC, register set, stack space
- 스레드들이 공유하는 자원
    - code, data, OS resource(파일, signals)
- 스레드 사용의 장점
    - responsiveness
        - 프로세스의 일부분이 중단되더라도 다른 스레드가 나머지 부분을 수행
    - resource sharing
        - 코드와 데이터를 공유, 같은 주소 공간 내에 여러 개의 다른 작업을 하는 스레드를 가질 수 있음
    - economy
        - 프로세스에 비해 스레드는 가벼움
    - scalability
        - 멀티코어 환경에서 병렬로 처리 가능

### Multicore Programming

## 4.3 Multithreading Models

### user threads

- 커널 위에서 지원되며 커널의 지원 없이 관리됨

### kernal threads

- 운영체제에 의해 직접 지원되고 관리됨

### 유저 스레드와 커널 스레드 관계

- 다대일 모델
    
    ![Untitled](Ch4%20Threads%20&%20Concurrency(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%2093064f16b3c34105bd45ba2a9e8628a1/Untitled%201.png)
    
- 일대일 모델
    
    ![Untitled](Ch4%20Threads%20&%20Concurrency(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%2093064f16b3c34105bd45ba2a9e8628a1/Untitled%202.png)
    
- 다대다 모델
    
    ![Untitled](Ch4%20Threads%20&%20Concurrency(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%2093064f16b3c34105bd45ba2a9e8628a1/Untitled%203.png)
    

## 4.6 Threading Issues

### fork(), exec()

- 한 스레드가 fork()를 호출하면 복제를 어떻게 해야 하는가?
    - 전체 프로세스를 복사
    - 해당 스레드만 복사
    - UNIX는 두 경우를 모두 지원
    - fork 하자마자 exec을 호출한다면 해당 스레드만 복사하는게 효율적
- Signal handling
    - 신호는 다음과 같은 형태로 전달됨
        - 신호는 특정 이벤트가 일어나야 생성된다
        - 생성된 신호가 프로세스에 전달된다
        - 신호가 전달되면 반드시 처리되어야 한다
    - 신호를 프로세스에 전달할 때 어떻게 해야 하는가
        - 신호가 적용될 스레드에게만 전달
        - 모든 스레드에 전달
        - 몇몇 스레드에만 선택적으로 전달
        - 특정 스레드가 모든 신호를 전달받도록 지정
- Thread Cancellation
    - 스레드가 끝나기 전에 강제 종료시키는 작업
    - 취소해야 할 스레드 : target thread
    - 취소될 때
        - asynchronous cancelltion
            - 한 스레드가 즉시 타겟 스레드를 강제 종료
            - 메모리 갱신 중 취소가 되는 문제
            - 시스템 자원을 운영체제가 회수하지 못할수도 있음
        - deferred cancellation: 타겟 스레드가 주기적으로 자신이 강제 종료되어야 하는지 점검