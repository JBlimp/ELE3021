# Ch5. CPU Scheduling(공룡책)

## 5.1 Basic Concepts

- multiprogramming: CPU 이용률을 최대화하기 위해 항상 실행 중인 프로세스를 가지게 하는 목적
- 어떤 프로세스를 실행할 것인지 정하는게 CPU 스케줄링

### CPU-I/O Burst Cycle

- 프로세스 실행의 구성
    
    ![Untitled](Ch5%20CPU%20Scheduling(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20d9e0b04a4d0e419bb5c2247866f106c2/Untitled.png)
    
    - CPU burst
        - CPU 실행
    - I/O burst
        - I/O wait

### Preemptive and Nonpreemptive Scheduling

- CPU 스케줄링이 발생하는 상황
    - nonpreemptive, cooperative, 자발적
        - running → wait
        - process 종료
    - preemptive, 강제적
        - running → ready
        - wait → ready

### Dispatcher

![Untitled](Ch5%20CPU%20Scheduling(%E1%84%80%E1%85%A9%E1%86%BC%E1%84%85%E1%85%AD%E1%86%BC%E1%84%8E%E1%85%A2%E1%86%A8)%20d9e0b04a4d0e419bb5c2247866f106c2/Untitled%201.png)

- CPU 코어의 control을 CPU 스케줄러가 선택한 프로세스에 주는 모듈
- 다음의 작업을 수행함
    - context switch
    - kernal mode → user mode
    - user program의 메모리 위치로 jump

## 5.2 Scheduling Criteria

- 알고리즘 평가의 기준
- CPU utilization
    - CPU 이용률
- throughput
    - 단위 시간당 완료된 프로세스 개수
- turnaround time
    - 총 처리 시간
- waiting time
    - ready queue에서 대기한 시간
- response time
    - 프로세스가 실행된 후 첫 응답하기까지 시간

## 5.3 Scheduling Algorithm

### FCFS Scheduling

### SJF Scheduling

### RR Scheduling

### Priority Scheduling

### Multilevel Queue Scheduling

### Multilevel Feedback Queue Scheduling