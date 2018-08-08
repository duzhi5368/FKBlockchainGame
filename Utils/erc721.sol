pragma solidity ^0.4.0;

// NFTs合约标准
// 和ERC-20发行的Token不同，ERC-72发行的每个Token是独一无二的，每个Token价值不同，不可分割，且可独立跟踪。
// ERC-721 Token适合做房地产，收藏品，游戏虚拟道具等物品
// ERC-20可以做游戏代币，但一开始就定义了货币总量不可更改
// ERC-621更适合做游戏代币，因为它可以动态增发和减发
contract erc721 {
    // indexed事件，表示该事件被过滤，只和该用户相关可以被“监听”
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approval, uint256 _tokenId);

    // 返回用户有多少个代币（僵尸）
    function balanceOf(address _owner) public view returns (uint256 _balance);
    // 一个代币所属的主人
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    // 转移代币所属（注意，该函数继承实现必须要调用 Transfer 事件进行通知）
    function transfer(address _to, uint256 _tokenId) public;
    // 存放代币，指定人可收取（注意，该函数继承实现必须要调用 Approval 事件进行通知）
    function approve(address _to, uint256 _tokenId) public;
    // 收取指定代币
    function takeOwnership(uint256 _tokenId) public;
}
