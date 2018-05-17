BTDelegates 是一个线程安全，调用安全的delegate事件分发器。传统的delegate模式默认只能支持一个对象的事件代理，BTDelegates可以支持多个对象的事件代理。你可以用来做这些事：
- 轻松地替代现有的单一delegate模式
- 用来分发现存的delegate的消息
- 对任意对象进行安全的消息分发



#### 替代单一delegate模式
传统delegate只能设置一个对象的代理，使用BTDelegates你可以轻松地设置多个对象的代理，而不需要进行太多修改。
- 传统写法
```
//定义weak属性
@property (nonatomic, weak) id<HostDelegate> delegate;

//设置代理
host.delegate = self;

//调用代理方法
if ([self.delegate respondsToSelector:@selector(onHostReturnHome:)]) {
    [self.delegate onHostReturnHome:self];
}

```
- BTDelegates写法
```
//定义strong/retain属性
@property (nonatomic, strong) BTDelegates<HostDelegate> *delegates; 

//在使用前你需要进行初始化
self.delegates = [BTDelegates delegates];

//添加代理
[host.delegates addDelegate:obj0];
[host.delegates addDelegate:obj1];

//调用代理方法
[self.delegates onHostReturnHome:self];
```



#### 分发现存的delegate的消息
假如一些类的delegate代码你无法修改，例如UITableView的delegate，你也可以通过以下方式来进行消息分发。原来你只能设置一个代理，那么现在你可以设置很多个了。
```
BTDelegates<HostDelegate> *delegateDispatcher = [BTDelegates delegates];
[delegateDispatcher addDelegate:obj0];
[delegateDispatcher addDelegate:obj1];

host.delegate = delegateDispatcher;
```



#### 任意对象的消息分发
对于拥有相同方法甚至不同方法的任意多个任意类型的对象，你都可以将他们添加到同一个BTDelegates对象中，你只需要调用一次接口，所有实现了该接口的对象就能收到消息，而没有实现该接口的对象不会收到消息。调用是安全的，你无须进行respondsToSelector:的判断。
```
id messageDispatcher = [BTDelegates delegates];
[delegateDispatcher addDelegate:obj0];
[delegateDispatcher addDelegate:obj1];

[delegateDispatcher onHostReturnHome:self];
```
