# node-lock

Node.js进程互斥锁:

Linux下默认读写`/dev/shm`.

Notice: 这一分支下开发试验性功能, 是互斥锁版本的分支, benchmark和unit test尚不完善, 切勿用于线上环境.

### TODO

+ Parser性能测试
+ 压力测试

原理: 由于Node的单进程单线程模型, 同一时间只允许一个阻塞任务执行,
利用这一机制在Linux内存映射文件系统`/dev/shm`上使用Node原生的阻塞读写函数, 可以实现多进程对同一块内存区域访问的读写互斥作用.

Notice: 由于资源访问的互斥性, 带来不可避免的同步原语, 因此任何异步执行是无意义的, 最终仍需要等待锁的释放, 所以服务端采用同步模型.
但C/S的结构允许客户端的异步请求, 这样就做到了异步互斥.

## Usage

```coffee
# master process
# lock server
LockProxy = require 'node-lock/proxy'

# LockServer [options]
# @options:
# + namespace: 命名空间(默认为"default")
# + dir: 共享内存位置, linux下默认为/dev/shm, osx需要手动指定一块已经创建区域
# m = LockProxy namespace: 'ddd', dir: '/Volume/shm'
# m = LockProxy namespace: 'ddd', dir: '/Volume/shm'
# 启动服务端
LockProxy().startStandAlone()
```

```coffee
# other process
LockClient = require 'node-lock'
client = new LockClient '/tmp/-tmp-default'
# 连接服务端socket
client.connect()
.then (resource) ->
  resource
  # read
  .retrieve 'Ran::*'
  .once 'retrieve', (ret) ->
    console.log entry.key, entry.value for entry in ret
  # write
  .delete 'key'
  # write
  .push 'key', 'value'
  # write
  .create 'key', 'value'
  # write
  .clean()
.catch (err) ->
  console.error err
```
