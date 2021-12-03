pragma ton-solidity = 0.47.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "include.sol";

contract AuthDebot is Debot {

    string _startStr = "Use external link for authorization";
    string _debotName = "itgold authentication debot";
    string _successStr = "Congratulations, authentication passed. Go back to the site.";
    string _failedStr = "Authentication FAILED.";
    string _signingBoxStr = "Please, sign authentication data with your key.";
    address _supportAddr = address.makeAddrStd(0, 0x5fb73ece6726d59b877c8194933383978312507d06dda5bcf948be9d727ede4b);

    string _id;
    string _otp;
    string _callbackUrl;
    uint32 _sigingBoxHandle;
    uint256 _userPubKey;
    address _userAddr;

    bytes _icon;

    modifier checkPubkey() {
        require(msg.pubkey() == tvm.pubkey(), 100);
        _;
    }

    function start() public override {
        Terminal.print(0, _startStr);
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = _debotName;
        version = "1.1";
        publisher = "https://itgold.io/";
        key = "User authentication";
        author = "https://itgold.io/";
        support = _supportAddr;
        hello = "I don't have default interaction flow. Invoke me.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = _icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID, 
            Network.ID, Base64.ID, UserInfo.ID, SigningBoxInput.ID  ];
    }

    function auth(string id, string otp, string callbackUrl) public {
        require(callbackUrl !="", 120);

        _id =  id;
        _otp = otp;
        _callbackUrl = callbackUrl;

        getAddress();
    }

    function getAddress() public {
        UserInfo.getAccount(tvm.functionId(getPublicKey));
    }

    function getPublicKey(address value) public {
        _userAddr = value;
        UserInfo.getPublicKey(tvm.functionId(setPk));
    }

    function setPk(uint256 value) public {
        uint256[] pubkeys;
        _userPubKey = value;
   		SigningBoxInput.get(tvm.functionId(setSigningBoxHandle), _signingBoxStr, pubkeys);
    }

    function setSigningBoxHandle(uint32 handle) public {
        uint256 hash = sha256(format("{}{}", _otp, _userAddr));
        Sdk.signHash(tvm.functionId(setSignature), handle, hash);
    }

    function setSignature(bytes signature) public {
        Base64.encode(tvm.functionId(setEncode), signature);
    }
 
    function setEncode(string base64) public returns(string){
        string[] headers;
        headers.push("Content-Type: application/x-www-form-urlencoded");
        string body = format("id={}&signature={}&addr={}&pk={:064x}", _id, base64, _userAddr, _userPubKey);
        Network.post(tvm.functionId(setResponse), _callbackUrl, headers, body);
    }

   function setResponse(int32 statusCode, string[] retHeaders, string content) public {
        retHeaders;
        content;
        if (statusCode == 200) {
            Terminal.print(0, _successStr);
        } else {
            Terminal.print(0, _failedStr);
        }
        noop("");
    }

    function getInvokeMessage(string id, string otp, string callbackUrl) public pure returns(TvmCell message) {
        message = tvm.buildIntMsg({
            dest: address(this),
            value: 0,
            bounce: true,
            call: { AuthDebot.auth, id, otp, callbackUrl }
        });
    }
    
    function noop(string value) public  {
        value;
        Terminal.input(tvm.functionId(noop), "", false);
    }

    function setIcon(bytes icon) public checkPubkey {
        tvm.accept();
        _icon = icon;
    }

    function setDebotName(string debotName) public checkPubkey {
        tvm.accept();
        _debotName = debotName;
    }

    function setStartStr(string startStr) public checkPubkey {
        tvm.accept();
        _startStr = startStr;
    }

    function setSuccessStr(string successStr) public checkPubkey {
        tvm.accept();
        _successStr = successStr;
    }

    function setFailedStr(string failedStr) public checkPubkey {
        tvm.accept();
        _failedStr = failedStr;
    }

    function setSigningBoxStr(string signingBoxStr) public checkPubkey {
        tvm.accept();
        _signingBoxStr = signingBoxStr;
    }

    function setSupportAddr(address supportAddr) public checkPubkey {
        tvm.accept();
        _supportAddr = supportAddr;
    }

    function burn(address dest) public checkPubkey {
        tvm.accept();
        selfdestruct(dest);
    }

}