import { expect, increase } from "chai";

const Oracle = artifacts.require("./Oracle.sol");

var o = null; // Oracle instance

function Get(url)
{
    var Httpreq = new XMLHttpRequest(); // a new request
    Httpreq.open("GET",url,false);
    Httpreq.send(null);
    return Httpreq.responseText;          
}

contract("Oracle", (accounts) => 
{
    describe("Run event", async()=>
    {
        before(async()=>
        {
            o = await Oracle.new();
        })
        
        it("It should get and set opening crawl", async()=>
        {
            let r = await o.Query(); // lets assume this functions is called by inner logic of contract

            // lets assume that this is event parser
            let eventName = r.logs[0].event;
            
            if (eventName == "EventRequestOpeningCrawl")
            {
                let jsonRet = await JSON.parse(Get("https://swapi.co/api/films/1/?format=json"));

                await o.SetOpeningCrawl(jsonRet.opening_crawl);

                expect(await o.openingCrawl()).to.equal(jsonRet.opening_crawl);
            }
        })

    })
})