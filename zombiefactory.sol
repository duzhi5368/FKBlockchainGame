pragma solidity ^0.4.0;

// #include or import
import "./Utils/ownable.sol";
import "./Utils/safemath.sol";


// is 是进行继承
// 继承子类可访问父类中公开函数，子类不可访问父类的private函数
// Ownable 验证调用者
contract ZombieFactory is Ownable {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    // 事件，用来将合约中的消息主动通知到链上
    // 前端可以注册监听函数，js如下
    // YourContract.NewZombie(function(error, result) { /*do something...*/ }
    event NewZombie(uint zombieId, string name, uint dna);

    // 这些变量会被永远写在链上
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;  // 10的X次方
    uint cooldownTime = 1 days;         // 时间对象seconds, minutes, hours, days, weeks, years

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        // 注意：下面有两个uint16，占用空间会减少
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;    // 这是一个动态数组， Public 变量会自动创建getter方法
    // Zombie[5] public zombies;  uint[2] private testArray 静态数组声明

    // mapping 将其视为dictionaryMap即可，key 为uint, value为address
    // address 格式是一个地址格式，是一个账户地址，一般格式类似 0x0cE446255506E92DF41614C46F1d6df9Cc969183
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // 命名习惯，参数用下划线开头，private， internal 函数使用下划线开头
    function _createZombie(string _name, uint _dna) internal {
        // 数组push，构造对象并初始化参数
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        // msg.sender 表示这个函数调用者的地址address
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);

        // 发送事件给链
        NewZombie(id, _name, _dna);
    }

    // view 表示仅仅读取类变量或全局变量，但不会写类变量和全局变量
    // pure 表示完全不读写类变量和全局变量，仅仅处理传入的参数
    function _generateRandomDna(string _str) private view returns (uint) {
        // keccak256 可将一个string进行hash为256整形
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        // 使用require限制，调用本函数的用户必须没有zombieCount
        // 类似assert断言，失败了则直接退出函数并抛出异常
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
