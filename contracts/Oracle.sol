pragma solidity 0.4.13;

contract Oracle
{
    string public openingCrawl;
    event EventRequestOpeningCrawl();

    function Query() public
    { EventRequestOpeningCrawl(); }

    function SetOpeningCrawl(string oc) public
    { openingCrawl = oc; }
}