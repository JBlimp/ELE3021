# Project02 wiki

### 2020087801 이준석

## Design

### 기존 구현

- MLFQ 스케줄러 구현을 위해 기존의 스케줄러가 어떻게 작동하는지 살펴보았다.
    - 시스템 부팅 및 초기화
        - 최초 부팅 시 main() 함수에서 init 프로세스를 allocproc() 함수를 통해 생성한다.
        - mpmain() 함수를 호출하여 CPU를 초기화하고 스케줄러를 시작한다.
    - 스케줄러 실행
        - mpmain() 함수에서 scheduler() 함수를 호출한다.
        - scheduler() 함수는 무한 루프를 돌며 ptable에서 실행 가능한 프로세스를 찾아 context switching을 수행한다.
    - 타이머 인터럽트
        - 인터럽트가 발생하면 trap() 함수가 호출된다.
        - trap() 함수 내에서 적절한 interrupt 처리를 수행한다. 스케줄러의 경우 timer interrupt를 발생시킨다.
    - 프로세스 종료
        - exit() 시스템 콜이 호출되면 프로세스의 상태를 ZOMBIE로 변경한다.
        - 부모 프로세스는 wait() 시스템 콜을 통해 자식 프로세스의 종료를 감지하고 resource를 회수한다.
        - ZOMBIE 상태의 프로세스는 부모 프로세스가 wait() 시스템 콜을 호출할 때까지 유지된다.

### 구현 계획

- 명세에 따라 scheduler() 함수에서 적절한 프로세스를 선택하고 trap(), exit(), allocproc() 함수 내에서 프로세스 생성, 종료에 대한 적절한 처리를 해 주면 된다.
    - proc.h 내에 정의되어 있는 struct proc에 구현에 필요한 변수를 추가해야 한다.
    - allocproc() 함수에서 프로세스가 생성될 때 적절한 처리를 해 주어야 한다.
    - scheduler() 함수에서 L0, L1, L2, L3 큐에서 실행 가능한 프로세스를 찾아 context switching을 수행해야 한다.
    - trap() 함수는 timer interrupt마다 호출되므로 1 tick 후 처리에 대한 과정을 trap() 함수에 구현하였다.
    - exit() 함수에서 프로세스가 종료될 때에 대한 처리를 해 주어야 한다.
    - trap() 함수에서 유저가 프로세스를 강제로 종료하는 상황을 처리하는 부분을 찾아 수정한다.

## Implement

### 작동 원리

- **부팅 후 스케줄러가 실행되기까지**
1. xv6가 부팅되면 main.c의 main()함수가 호출된다.
2. main() 함수는 첫 번째 프로세스 생성을 위해 userinit() 함수를 호출한다.
3. userinit() 함수는 allocproc()을 호출하여 첫 번째 프로세스 init을 할당한다.
4. main()에서 mpmain()을 호출한다. mpmain()에서는 scheduler()를 호출하여 스케줄러를 실행한다.
- **스케줄러 작동**
1. 무한 루프를 돌며 현재 모드가 monopolize 모드인지 mlfq 모드인지를 확인한다.
2. monopolize 모드일 경우
    1. monopolize 모드인 경우 MoQ에 편입된 순서대로 스케줄링을 진행한다.
    2. MoQ가 비었으면 unmonopolize() 함수를 호출한다.
3. mlfq 모드일 경우
    1. 가장 높은 큐부터 실행할 수 있는 프로세스를 탐색한다.
- **타이머 인터럽트**
1. 매 tick마다 타이머 인터럽트가 발생한다.
2. global tick을 1 늘림과 동시에 현재 실행중인 프로세스의 quantum을 1 감소시킨다.
3. 명세대로 quantum이 0이 되었을때의 작업을 수행한다.
4. quantum이 0이 되어 큐간 이동이 발생하면, yield()를 호출하여 CPU 점유를 포기한다.
5. yield()에서는 sched()를 호출하여 현재 실행중인 프로세스와 scheduler와의 context switch를 수행한다. 즉, 스케줄러를 다시 호출하여 다음 프로세스를 실행한다.

### system-call 구현

- **Wrapper function**
    
    ```c
    int
    sys_yield(void)
    {
      yield();
      return 0;
    }
    
    int
    sys_getlev(void)
    {
      return getlev();
    }
    
    int
    sys_setpriority(void)
    {
      int pid, priority;
      if(argint(0, &pid) < 0)
        return -1;
      if(argint(1, &priority) < 0)
        return -1;
    
      return setpriority(pid, priority);
    }
    
    int
    sys_setmonopoly(void)
    {
      int pid, password;
      if(argint(0, &pid) < 0)
        return -1;
      if(argint(1, &password) < 0)
        return -1;
      return setmonopoly(pid, password);
    }
    
    int
    sys_monopolize(void)
    {
      monopolize();
      return 0;
    }
    
    int
    sys_unmonopolize(void)
    {
      unmonopolize();
      return 0;
    }
    ```
    
    - 과제 명세의 system-call들에 대한 wrapper function들이다. 인자 처리 후 실제 system-call을 호출한다.
    - 실제 system-call은 전부 proc.c에 구현하였다.
- **yield**
    - yield()는 proc.c에 구현되어 있는 yield 함수를 그대로 이용하였다.
- **getlev**
    
    ```c
    int 
    getlev(void)
    {
      return myproc()->level;
    }
    ```
    
    - myproc()은 현재 실행중인 프로세스를 리턴하는 함수이다. proc 구조체에 추가한 level을 리턴한다.
- **setpriority**
    
    ```c
    int
    setpriority(int pid, int priority)
    {
      if (priority < 0 || priority > 10) {
        return -2;
      }
    
      struct proc *p;
      p = find_with_pid(pid);
      if (p == NULL) {
        return -1;
      }
    
      p->priority = priority;
      return 0;
    }
    ```
    
    - 추가로 구현한 find_with_pid 함수를 호출하여 pid를 가진 프로세스 포인터 p를 구한 후 p의 priority 값을 수정한다.
    - xv6는 NULL이 정의되어 있지 않지만, 구현의 편의를 위해 #define NULL 0을 추가하여 사용하였다.
- **setmonopoly**
    
    ```c
    int
    setmonopoly(int pid, int password)
    {
      if (password != 2020087801) {
        return -2;
      }
      struct proc *p;
      p = find_with_pid(pid);
      if (p == NULL) {
        return -1;
      }
    
      p->priority = moq_priority++;
      p->level = 99;
      p->state = RUNNABLE;
      moq_cnt++;
    
      return moq_cnt;
    }
    ```
    
    - 추가로 구현한 find_with_pid 함수를 호출하여 pid를 가진 프로세스 포인터 p를 구한 후 level을 99로 설정한다. 그 후 MoQ 의 길이를 의미하는 전역변수인 moq_cnt의 값을 1 증가시킨다.
- **monopolize, unmonopolize**
    
    ```c
    void
    monopolize(void) 
    {
      is_monopolized = 1;
    }
    
    void 
    unmonopolize(void) 
    {
      is_monopolized = 0;
    }
    ```
    
    - 현재 monopolize 모드인지를 의미하는 전역변수 is_monopolized의 값을 수정한다.

### MLFQ+MoQ 스케줄러 구현

- **proc.h의 proc 구조체에 quantum, priority, level 변수를 추가하였다.**
    
    ```c
    struct proc {
      ...
      //project02, mlfq
      int quantum; // cpu time spent by process
      int priority; 
      int level; // current queue level
    };
    ```
    
    - quantum: 남은 time quantum
    - priority: L3 큐에서는 우선순위를 의미 / MoQ에서는 MoQ에 편입된 순서를 의미
    - level: 현재 process가 속해있는 Queue의 Level, MoQ의 경우 99를 저장한다.
- **proc.c에 구현을 위한 전역변수를 추가하였다.**
    
    ```c
    #define NULL 0
    int is_monopolized = 0;
    int moq_cnt = 0;
    int moq_priority = 0;
    int queue_position[4] = {0, 0, 0, 0};
    ```
    
    - 구현의 편의를 위해 0을 NULL로 define 하였다.
    - is_monopolized: 현재 모드가 monopolize 모드인지를 의미
    - moq_cnt: MoQ 내의 프로세스 개수
    - moq_priority: MoQ에 편입된 순서. MoQ에 프로세스가 편입될 때마다 1씩 증가한다.
    - queue_position: 각 mlfq에서 마지막으로 실행된 프로세스의 ptable에서의 인덱스를 저장한다. 큐를 따로 구현하지 않고 ptable을 이용하였기에 필요한 변수이다.
- **allocproc()**
    
    ```c
    static struct proc*
    allocproc(void)
    {
      ...
      p->level = 0;
      p->quantum = 2;
      p->priority = 0;
      ...
    }
    ```
    
    - 새로 생성되는 프로세스는 L0 큐에 편입되므로 level = 0, quantum = 2, priority = 0으로 설정한다.
- **exit()**
    
    ```c
    void
    exit(void)
    {
    	...
      if (curproc->level == 99) {
        moq_cnt--;
      }
    	...
    }
    ```
    
    - 프로세스가 종료될 때 호출되는 함수이다. MoQ에 있는 프로세스라면 MoQ의 프로세스 개수를 카운트하는 변수인 moq_cnt 변수의 값을 1 감소시킨다.
- i**s_runnable()**
    
    ```c
    int
    is_runnable(struct proc* p)
    {
      if (p != NULL) {
        if (p->state == RUNNABLE && p->quantum > 0 && p->level < 4) {
          return 1;
        }
      }
      return 0;
    }
    ```
    
    - p가 mlfq 내에서 ready 상태라면 1을 리턴하고 아니면 0을 리턴한다.
- **priority_boosting()**
    
    ```c
    int
    priority_boosting(void)
    {
      struct proc* p;
      acquire(&ptable.lock);
      for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->level == 0) {
          p->quantum = 2;
        } else if (p->level >= 1 && p->level <= 3) {
          p->level = 0;
          p->quantum = 2;
        }
      }
      release(&ptable.lock);
      queue_position[0] = 0;
      queue_position[1] = 0;
      queue_position[2] = 0;
      queue_position[3] = 0;
      return 1;
    }
    ```
    
    - 하위 큐의 starvation을 방지하기 위해 100 tick마다 호출되며 호출시 mlfq 내의 모든 프로세스를 L0 큐로 올리고 time quantum을 초기화한다.
    - 이전에 해당 큐에서 실행했던 프로세스의 위치는 필요가 없어지므로 공정한 스케줄링을 위해 0으로 초기화한다.
- **can_mlfq()**
    
    ```c
    int
    can_mlfq(int level)
    {
      struct proc* p;
      acquire(&ptable.lock);
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->level == level && p->state == RUNNABLE) {
          release(&ptable.lock);
          return 1;
        }
      }
      release(&ptable.lock);
      return 0;
    }
    ```
    
    - 인자로 받은 level의 mlfq에 스케줄링 가능한 프로세스가 있는지 리턴한다.
- **next_proc()**
    
    ```c
    struct proc*
    next_proc(int level)
    {
      struct proc* p;
      int i, start;
      if (level >= 0 && level <= 2) {
        for (i = 0; i < NPROC; i++) {
          start = (queue_position[level] + i) % NPROC;
          p = &ptable.proc[start];
          if (p->level == level && p->state == RUNNABLE) {
            queue_position[level] = start + i;
            return p;
          }
        }
      } else if (level == 3) {
        struct proc* temp = NULL;
        for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
          if (p->state != RUNNABLE) {
            continue;
          }
    
          if (p->level == 3) {
            if (temp == NULL) {
              temp = p;
            } else {
              if (temp->priority < p->priority) {
                temp = p;
              }
            }
          }
        }
        queue_position[level] = (temp - ptable.proc + 1) % NPROC;
        return temp;
      } else if (level == 99) {
        struct proc* temp = NULL;
        for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
          if (p->state != RUNNABLE) {
            continue;
          }
    
          if (p->level == 99) {
            if (temp == NULL) {
              temp = p;
            } else {
              if (temp->priority > p->priority) {
                temp = p;
              }
            }
          }
        }
        return temp;
      }
      return NULL;
    }
    ```
    
    - 다음 스케줄링할 프로세스를 리턴한다.
    - ptable을 L0, L1, L2, L3 큐가 통합된 원형큐처럼 생각하고 구현하였다.
    - 마지막으로 수행한 프로세스가 위치했던 index부터 스케줄링 가능한 프로세스를 찾는다.
    - L0 ~ L2 큐에서는 state check만 진행한다.
    - L3 큐에서는 state check와 함께 priority까지 고려한다.
    - MoQ에서는 편입된 순서까지 고려한다.
        - MoQ의 프로세스에서 priority는 MoQ에 편입된 순서를 의미한다. priority가 작은 프로세스부터 스케줄링을 수행한다.
    - 스케줄링 우선순위를 정리하자면 다음과 같다.
        - L0, L1, L2 큐에서는 ptable에서의 순서대로 스케줄링을 수행한다. 프로세스가 생성된 순서대로이기 때문에 주로 pid 순서대로 스케줄링이 수행된다.
        - L3 큐에서는 priority가 가장 큰 프로세스부터 스케줄링을 수행한다. priority가 모두 같을 경우 상위 큐와 마찬가지로 ptable에서의 순서대로 스케줄링을 수행한다.
        - MoQ에서는 FCFS 방식으로 스케줄링을 수행한다.
- **find_with_pid()**
    
    ```c
    struct proc*
    find_with_pid(int pid)
    {
      struct proc* p;
      acquire(&ptable.lock);
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->pid == pid) {
          release(&ptable.lock);
          return p;
        }
      }
      release(&ptable.lock);
      return NULL;
    }
    ```
    
    - 해당 pid를 가진 프로세스 포인터를 리턴한다.
- **scheduler()**
    
    ```c
    void
    scheduler(void)
    {
      struct proc *p;
      struct cpu *c = mycpu();
      c->proc = 0;
      int i;
    
      for(;;) {
        sti();
        
        // if monopolize
        if (is_monopolized == 1) {
          acquire(&ptable.lock);
          p = next_proc(99);
          release(&ptable.lock);
    
    			// MoQ 비었으면 unmonopolize
          if (p == NULL) {
            if (moq_cnt == 0) {
              unmonopolize();
            }
            continue;
          }
    
    			// context switch
          acquire(&ptable.lock);
          c->proc = p;
          switchuvm(p);
          p->state = RUNNING;
          swtch(&(c->scheduler), p->context);
          switchkvm();
          release(&ptable.lock);
    
          continue;
        }
        
        // if mlfq
        // 가장 높은 큐부터 다음 실행할 수 있는 프로세스를 탐색
        for (i = 0; i <= 3; i++) {
          if (can_mlfq(i)) {
            acquire(&ptable.lock);
            p = next_proc(i);
            release(&ptable.lock);
            break;
          }
        }
    
        // 만약 스케줄링할 수 있는 프로세스가 없으면 루프 처음부터 다시
        if (i == 4) {
          continue;
        }
    
        // context switch
        acquire(&ptable.lock);
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;
        swtch(&(c->scheduler), p->context);
        switchkvm();
        release(&ptable.lock);
      }
    }
    ```
    
    - 기존의 스케줄러와 동일하게 무한루프를 돌며 스케줄링 가능한 프로세스를 찾아 context switch를 수행한다.
    - is_monopolized 변수를 확인해 MoQ를 스케줄링할지 MLFQ를 스케줄링할지 결정한다.
    - MoQ일 경우
        - next_proc()를 호출해 다음 스케줄링할 프로세스를 찾는다.
        - 변수 moq_cnt 를 확인해 MoQ가 비었을 경우 unmonopolize()를 호출한다.
        - context switch를 수행한다.
    - MLFQ일 경우
        - 가장 높은 우선순위의 큐부터 스케줄링 가능한 프로세스를 찾는다.
        - context switch를 수행한다.
- **trap()**
    
    ```c
    void
    trap(struct trapframe *tf)
    {
      ...
      switch(tf->trapno){
      case T_IRQ0 + IRQ_TIMER:
        if(cpuid() == 0){
          acquire(&tickslock);
          ticks++;
          // global tick이 증가할 때 현재 실행중인 proc의 time quantum도 수정
          if (myproc() && myproc()->state == RUNNING) {
            myproc()->quantum--;
          }
          wakeup(&ticks);
          release(&tickslock);
        }
        lapiceoi();
        break;
    	...
      // 1 tick 후처리
      if (myproc() && myproc()->state == RUNNING &&
         myproc()->level == 0 &&
         myproc()->quantum <= 0) {
          if (myproc()->pid % 2 == 0) {
            myproc()->level = 2;
            myproc()->quantum = 6;
            yield();
          } else {
            myproc()->level = 1;
            myproc()->quantum = 4;
            yield();
          }
      }
      if (myproc() && myproc()->state == RUNNING &&
        (myproc()->level == 1 || myproc()->level == 2) && 
          myproc()->quantum <= 0) {
            myproc()->quantum = 8;
            myproc()->level = 3;
            yield();
      }
      if (myproc() && myproc()->state == RUNNING &&
          myproc()->level == 3 &&
          myproc()->quantum <= 0) {
            myproc()->quantum = 8;
            myproc()->priority--;
            if (myproc()->priority < 0) {
              myproc()->priority = 0;
            }
            yield();
      }
      acquire(&tickslock);
      if (ticks % 100 == 0) {
        priority_boosting();
      }
      release(&tickslock);
    	
    }
    ```
    
    - trap 함수의 case T_RIQ0 + IRQ_TIMER 레이블은 Timer Interrupt를 처리하는 부분이다. 현재 실행중인 프로세스의 quantum을 1 감소시킨다.
    - 1 tick마다 수행해야 하는 작업은 switch-case문 뒤에 구현하였다. 단계는 다음과 같다.
    - L0큐에 있으며 Time Quantum을 다 소진했을 때
        - pid가 홀수이면 L1큐로 옮기고 yield 호출
        - pid가 짝수이면 L2 큐로 옮기고 yield 호출
    - L1, L2큐에 있으며 Time Quantum을 다 소진했을 때
        - L3 큐로 옮기고 yield 호출
    - L3 큐에 있으며 Time Quantum을 다 소진했을 때
        - priority를 1 감소시키고 quantum 초기화
        - yield 호출
    - global tick이 100이 될 때마다 priority boosting을 수행한다.
    - yield()를 호출함으로서 yield()에서 sched()를 호출하고 sched()에서 scheduler()가 실행되니 다음 프로세스를 스케줄링할 수 있다.
- **Force Kill**
    - trap()
    
    ```c
    void
    trap(struct trapframe *tf)
    {
    	...
      default:
        if(myproc() == 0 || (tf->cs&3) == 0){
          // In kernel, it must be our mistake.
          cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
                  tf->trapno, cpuid(), tf->eip, rcr2());
          panic("trap");
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
                "eip 0x%x addr 0x%x--kill proc\n",
                myproc()->pid, myproc()->name, tf->trapno,
                tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
      }
    	...
      // Check if the process has been killed since we yielded
      if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER) {
        cprintf("Process forcibly terminated by User\n");
        exit();
      }
    }
    ```
    
    - switch case문의 default 레이블에서 프로세스 강제 종료를 처리한다.
    - switch case문 뒤의 if문을 통해 강제 종료된 프로세스를 정리하는데, 이 부분에서 프로세스가 강제 종료되었다는 메세지를 출력한다.

## Result

- test1
    
    ![Untitled](Project02/Untitled.png)
    
    - 명세와 다르게 짝수 PID의 프로세스가 먼저 끝남을 알 수 있는데, L3 큐에서 우선순위가 모두 같을 시 큐에 편입된 순서가 아닌 PID 순서대로 스케줄링을 진행하기 때문이다.
    - time quantum이 L1 큐보다 L2 큐가 더 크기에 위와 같은 결과가 나오는 것으로 생각된다.
- test2
    
    ![Untitled](Project02/Untitled%201.png)
    
    - 우선순위(PID)가 큰 프로세스가 대체적으로 먼저 끝난다.
- test3
    
    ![Untitled](Project02/Untitled%202.png)
    
    - 대부분 L0 큐에 머무르기 때문에 pid가 작은 프로세스가 대체적으로 먼저 끝난다.
    - sleep 상태에 있는 동안에는 스케줄링 되지 않기 때문에 거의 동시에 끝난다.
- test4
    
    ![Untitled](Project02/Untitled%203.png)
    
    - MoQ의 프로세스들은 FCFS 방식으로 스케줄링 되므로 pid가 작은 프로세스가 먼저 끝난다.

## Trouble Shooting

- 최초 구상에서 quantum을 감소시키는 부분을 Timer Interrupt가 발생할 때마다 수행하는 게 아닌 scheduler()의 for 반복문이 1회 수행될 때마다 감소되도록 설계하였다.
    - for 반복문 1회가 tick이 아니라 타이머 인터럽트가 발생하는 주기가 tick이기 때문에 trap에서 타이머 인터럽트를 다루는 부분에서 quantum을 감소시키도록 수정하였다.
- 최초 구상에서 별도의 Queue로 L0, L1, L2, L3, MoQ를 구현하고 enqueue, dequeue 함수를 호출하여 프로세스를 관리하였다.
    - xv6의 기본 스케줄러가 Round-Robin 정책을 사용하고 있음을 이용하여 L0, L1, L2의 스케줄링을 별도의 Queue에서 enqueue, dequeue하여 수행하는 것이 아닌 xv6의 기본 스케줄러의 방식과 같이 변경하였다.
    - 명세에서는 Queue를 구현하여 사용하라는 언급이 없었고, MLFQ의 각 큐에서 스케줄링의 순서도 언급이 없었기에 굳이 Queue를 구현할 필요가 없다고 판단하였다.
    - 이를 통해 불필요한 Queue와 함수 호출을 줄여 스케줄링의 Overhead를 줄일 수 있었다.