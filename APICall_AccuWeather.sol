// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

// (0) Deploy the contract on Kovan network
// (1) provide some LINK tokens and send them to your contract
// (2) Execute requestLocationCurrentConditions() function with your desired inputs
// (3) call 0 index of locationCurrentConditionsArray[] and copy it
// (4) Enter it on all of available mappings inputs to see results

contract WeatherOracle is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    bytes32[] public locationCurrentConditionsArray;

    /* ========== CONSUMER STATE VARIABLES ========== */

    struct RequestParams {
        uint256 locationKey;
        string endpoint;
        string lat;
        string lon;
        string units;
    }
    struct LocationResult {
        uint256 locationKey;
        string name;
        bytes2 countryCode;
    }
    struct CurrentConditionsResult {
        uint256 timestamp;
        uint24 precipitationPast12Hours;
        uint24 precipitationPast24Hours;
        uint24 precipitationPastHour;
        uint24 pressure;
        int16 temperature;
        uint16 windDirectionDegrees;
        uint16 windSpeed;
        uint8 precipitationType;
        uint8 relativeHumidity;
        uint8 uvIndex;
        uint8 weatherIcon;
    }

    // Maps
    mapping(bytes32 => CurrentConditionsResult) public requestIdCurrentConditionsResult;
    mapping(bytes32 => LocationResult) public requestIdLocationResult;
    mapping(bytes32 => RequestParams) public requestIdRequestParams;

    /* ========== CONSTRUCTOR ========== */

    constructor() {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        setChainlinkOracle(0xfF07C97631Ff3bAb5e5e5660Cdf47AdEd8D4d4Fd);
    }

    /* ========== CONSUMER REQUEST FUNCTIONS ========== */

    /**
     * @notice Returns the current weather conditions of a location for the given coordinates.
     * @param _lat the latitude (WGS84 standard, from -90 to 90).
     * @param _lon the longitude (WGS84 standard, from -180 to 180).
     * @param _units the measurement system ("metric" or "imperial").
     */

    // Sample : Tehran, Iran
    // Latitude: 35.689198
    // Longitude: 51.388974
    // unit : metric

    function requestLocationCurrentConditions(
        string calldata _lat,
        string calldata _lon,
        string calldata _units
    ) public {
        Chainlink.Request memory req = buildChainlinkRequest(
            0x3763323736393836653233623462316339393064383635396263613761396430,
            address(this),
            this.fulfillLocationCurrentConditions.selector
        );

        req.add("endpoint", "location-current-conditions"); // NB: not required if it has been hardcoded in the job spec
        req.add("lat", _lat);
        req.add("lon", _lon);
        req.add("units", _units);

        bytes32 requestId = sendChainlinkRequest(req, 1000000000000000000);

        // Below this line is just an example of usage
        storeRequestParams(requestId, 0, "location-current-conditions", _lat, _lon, _units);

        locationCurrentConditionsArray.push(requestId);

    }

    /* ========== CONSUMER FULFILL FUNCTIONS ========== */

    function fulfillLocationCurrentConditions(
        bytes32 _requestId,
        bool _locationFound,
        bytes memory _locationResult,
        bytes memory _currentConditionsResult
    ) public recordChainlinkFulfillment(_requestId) {
        if (_locationFound) {
            storeLocationResult(_requestId, _locationResult);
            storeCurrentConditionsResult(_requestId, _currentConditionsResult);
        }
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function storeRequestParams(
        bytes32 _requestId,
        uint256 _locationKey,
        string memory _endpoint,
        string memory _lat,
        string memory _lon,
        string memory _units
    ) private {
        RequestParams memory requestParams;
        requestParams.locationKey = _locationKey;
        requestParams.endpoint = _endpoint;
        requestParams.lat = _lat;
        requestParams.lon = _lon;
        requestParams.units = _units;
        requestIdRequestParams[_requestId] = requestParams;
    }

    function storeLocationResult(bytes32 _requestId, bytes memory _locationResult) private {
        LocationResult memory result = abi.decode(_locationResult, (LocationResult));
        requestIdLocationResult[_requestId] = result;
    }

    function storeCurrentConditionsResult(bytes32 _requestId, bytes memory _currentConditionsResult) private {
        CurrentConditionsResult memory result = abi.decode(_currentConditionsResult, (CurrentConditionsResult));
        requestIdCurrentConditionsResult[_requestId] = result;
    }

    /* ========== OTHER FUNCTIONS ========== */

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function withdrawLink() public {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }
}
