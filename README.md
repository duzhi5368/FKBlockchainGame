- 在区块链中安全的生成随机数很困难，注意。
- 一个合约在链上，实际上不会进行任何执行，必须外界进行调用。
- 合约中的每个public, external函数是可以被外界任何人调用的。
- 一旦我们将智能协议传到以太坊后，代码就不可更改。
- 合约支持多重继承。函数支持多重修饰符限定。
- 函数类型： 
    - public 无论合约内，合约外均可调用
    - internal 本合约内，子合约可调用
    - private 只能本合约调用，子合约和外部不可调用
    - external 只能外部合约调用，本合约不可调用
            
- 变量内存类型：
    - storage 默认合约内类变量类型，永久存储，存储在链上
    - memory 默认函数内变量类型，出函数即从内存销毁，不存储
    
- 特殊关键字
    - ether 付费单位，例如：uint levelUpFee = 0.001 ether; 
    - seconds, minutes, hours, days, weeks, years 时间单位，例如：uint cooldownTime = 1 days;
    - onlyOwner 函数修饰符，强调本函数只能合约缔造者调用
    - view/pure 函数修饰符，见专题
    - payable 函数修饰符，用以接受以太币的关键字
    - indexed 参数修饰符，过滤事件只有事件相关者可以监听
    
- View/pure函数类型
    - 不可修改区块链数据，但可读取。该函数不消耗gas
    - 如果一个View函数在另一个函数内被调用，而调用函数和view函数不在一个合约中，则view也会消耗调用成本
    - View函数被外部调用时才为免费
    - view 表示仅仅读取类变量或全局变量，但不会写类变量和全局变量
    - pure 表示完全不读写类变量和全局变量，仅仅处理传入的参数
    
- payable函数修饰符
    - 用来指定一个函数执行费用
    - 例如: contract OnlineStoreContract {
                function buySomething() external payable {
                // 检查以确定0.001以太发送出去来运行函数:
                require(msg.value == 0.001 ether);
                // 如果为真，一些用来向函数调用者发送数字内容的逻辑
                transferThing(msg.sender);
              }
            }
      在Dapp前端web3.js调用该函数代码为，表示前端用户要买一个东西
      OnlineStoreContract.buySomething().send(from: web3.eth.defaultAccount, value: web3.utils.toWei(0.001))
    - 如果一个函数未被表示为payable，则发送以太会报错
    - 发送出去的以太币会被存储在合约的以太坊账户，如果想取钱，使用如下代码
        contract GetPaid is Ownable {
          function withdraw() external onlyOwner {
            owner.transfer(this.balance);
          }
        }
    - 其中transfer可以给任何地址发送以太，this.balance是这个合约中的以太数量
    - 当然可以自动化的发送以太币到收款人处，那么在每个购买商品的代码下方加入
        owner.transfer(msg.value); 就好
    
    
- 逆天的设计
    - 为了保存 用户->其拥有僵尸 的映射，我们最简单的方式是创建一个mapping (address => uint[]) public ownerToZombies的映射
    - 以后创建僵尸时，只要ownerToZombies[owner].push(zombieId)即可，超级简单
    - 但是可是如果我们需要一个函数来把一头僵尸转移到另一个主人名下，又会发生什么？
    - 这个“换主”函数要做到：
        1.将僵尸push到新主人的 ownerToZombies 数组中
        2.从旧主的 ownerToZombies 数组中移除僵尸
        3.将旧主僵尸数组中“换主僵尸”之后的的每头僵尸都往前挪一位，把挪走“换主僵尸”后留下的“空槽”填上
        4.将数组长度减1。
        但是第三步实在是太贵了！因为每挪动一头僵尸，我们都要执行一次写操作。
        如果一个主人有20头僵尸，而第一头被挪走了，那为了保持数组的顺序，我们得做19个写操作。
        由于写入存储是 Solidity 中最费 gas 的操作之一，使得换主函数的每次调用都非常昂贵。
        更糟糕的是，每次调用的时候花费的 gas 都不同！具体还取决于用户在原主军团中的僵尸头数，以及移走的僵尸所在的位置。以至于用户都不知道应该支付多少 gas。
        注意：当然，我们也可以把数组中最后一个僵尸往前挪来填补空槽，并将数组长度减少一。但这样每做一笔交易，都会改变僵尸军团的秩序。
        由于从外部调用一个 view 函数是免费的，我们也可以在 getZombiesByOwner 函数中用一个for循环遍历整个僵尸数组，把属于某个主人的僵尸挑出来构建出僵尸数组。
        那么我们的 transfer 函数将会便宜得多，因为我们不需要挪动存储里的僵尸数组重新排序，总体上这个方法会更便宜，虽然有点反直觉。
        这里可以参见 ZombieHelper.sol 中的 getZombiesByOwner 函数实现。
        
# 推荐

    - 使用 natspec 格式的注释
    - OpenZepplin 做合约支持库
    - web3.js 做网页前端以太坊交互库
    - 使用Loom做免费测试侧链
    - infura 用来做web3节点提供者，免去自己运营处理节点
    - Metamask 可以很便捷的管理私钥，默认使用infura节点