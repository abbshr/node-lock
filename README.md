# node-shm

share-memory library

## install

```sh
npm install -save node-shm
```

## run test

```sh
# 全部测试用例
npm test
# or
cake test

# 运行单个测试, 如create
cake -c create test
```

## Usage

### callback写法
```coffee
Shm = require '@ali/node-shm'

# new Shm [options]
# @options:
# + namespace: 命名空间(默认为"default/")
# + dir: 共享内存位置, linux下默认为/dev/shm, osx需要手动指定一块已经创建区域
# m = new Shm namespace: 'ddd/', dir: 'Volume/shm'
m = new Shm

m.retrieve key, (err, ret) -> # key支持通配符*
m.delete key, (err) ->
m.delete (err) -> # delete all keys
m.push key, value, (err) ->
m.create key, value, (err) ->
```

### 事件写法
```coffee
  m
  .once 'end', (ret) ->
    console.log ret
    # ret是一个包含返回数据和key的数组
    # => [{key: 'xx', value: 'xx'}, ...]
  .once 'created', () ->
    console.log 'created key & data'
  .once 'finish', () ->
    console.log 'append data'
  .on 'error', (err) ->
    console.log err
  .create 'key', 'value'
  .retrieve 'key*'
  .push 'key1', 'value'
  .delete 'key'
  .delete()
  .on 'deleted', () ->
    console.log 'del'
```

#### 事件列表
```coffee
"end": .retrieve()
"deleted": .delete()
"finished": .push()
"created": .create()
"error"
```

### ~~(已废弃) Promise写法~~
```coffee
  # Shm = require 'node-shm'
  #
  # m = new Shm
  #
  # # 使用前必须mount
  # m.mount()
  # # => Promise
  # .then () ->
  #   # 创建/覆盖一个key，同时写入值
  #   m.create "qb45", "I 'm value"
  #   # => Promise
  # .then () ->
  #   # 根据key获取数据
  #   m.retrieve key
  #   # => Promise
  # .then (value) ->
  #   # => Buffer
  #   console.log value.toString()
  #   # 追加数据
  #   m.push 'qb45', "appendee"
  #   # => Promise
  # .then () ->
  #   # 删除一个key
  #   m.delete 'qb45'
  #   # => Promise
  # .then () ->
  #   # 直接强制丢弃激活的内存区域
  #   m.detach()
  #   # => Promise
  # .then () ->
  #   console.log 'detached'
  # .catch (err) ->
  #   console.error err
```
