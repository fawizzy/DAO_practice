// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract DAO {
    address immutable owner;
    uint256 proposalId = 0;

    mapping(address => bool) isMember;
    mapping(address => bool) isAdmin;

    mapping(uint256 proposalId => mapping(address => bool)) hasVote;
    mapping(uint256 proposalId => Proposal) idToProposal;

    enum Status {
        PENDING,
        PASSED,
        FAILED
    }

    struct Proposal {
        uint256 id;
        string title;
        Status status;
        uint256 approveCount;
        uint256 rejectCount;
    }

    Proposal[] acceptedProposals;
    Proposal[] rejectedProposals;

    constructor(address admin1, address admin2, address admin3) {
        owner = msg.sender;
        isAdmin[admin1] = true;
        isAdmin[admin2] = true;
        isAdmin[admin3] = true;

    }

    function joinDAO() external {
        isMember[msg.sender] = true;
    }

    function addAdmin(address admin) external OnlyOwner {
        isAdmin[admin] = true;
    }

    function vote(
        uint256 _proposalId,
        bool _approve
    ) external OnlyAdmin HasVote(_proposalId) {
        require(
            idToProposal[_proposalId].status == Status.PENDING,
            "Proposal has been finalised"
        );
        if (_approve) {
            idToProposal[_proposalId].approveCount++;
            if (idToProposal[_proposalId].approveCount > 1) {
                idToProposal[_proposalId].status = Status.PASSED;
                acceptedProposals.push(idToProposal[_proposalId]);
            }
        } else {
            idToProposal[_proposalId].rejectCount++;
            if (idToProposal[_proposalId].rejectCount > 1) {
              idToProposal[_proposalId].status = Status.FAILED;
                rejectedProposals.push(idToProposal[_proposalId]);
            }
        }
    }

    function createProposal(
        string memory _title
    ) external {
        idToProposal[proposalId] = Proposal(
            proposalId,
            _title,
            Status.PENDING,
            0,
            0
        );

        proposalId++;
    }

    function getProposalById(uint256 _id) external view returns (Proposal memory) {
        return idToProposal[_id];
    }

    function getAcceptedProposal() external view returns (Proposal[] memory) {
        return acceptedProposals;
    }

    function getRejectedProposal() external view returns (Proposal[] memory) {
        return rejectedProposals;
    }

    modifier OnlyOwner() {
        require(owner == msg.sender, "only owner can do this");
        _;
    }

    modifier OnlyAdmin() {
        require(isAdmin[msg.sender], "only admin can vote");
        _;
    }

    modifier HasVote(uint256 _proposalId) {
        require(
            hasVote[_proposalId][msg.sender] == false,
            "voted this proposal already"
        );
        _;
    }
}
