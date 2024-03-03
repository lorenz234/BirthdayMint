// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FHE, euint8, euint16, inEuint8, inEuint16, ebool } from "@fhenixprotocol/contracts/FHE.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Birthday_token is ERC20, Ownable {
    constructor() ERC20("BirthdayToken", "BDY") Ownable(msg.sender) {}

    // Mapping from an address to bday timestamp
    mapping(address => euint8) internal dayMapping;
    mapping(address => euint8) internal monthMapping;
    mapping(address => euint16) internal yearMapping;

    // set your birthday
    function set_bday(inEuint8 calldata day, inEuint8 calldata month, inEuint16 calldata year) public {
        euint8 _day = FHE.asEuint8(day); 
        euint8 _month = FHE.asEuint8(month); 
        euint16 _year = FHE.asEuint16(year); 
        if (!FHE.isInitialized(dayMapping[msg.sender])) {
            // do nothing as bday already in the system
        } else {
            dayMapping[msg.sender] = _day;
            monthMapping[msg.sender] = _month;
            yearMapping[msg.sender] = _year;
        }
    }

    // check if today is your birthday & if yes you mint 100 tokens
    function mint_ifBirthday() public {
        (uint8 day, uint8 month) = getDayAndMonth(block.timestamp);
        euint8 dayNow = FHE.asEuint8(day);
        euint8 monthNow = FHE.asEuint8(month);
        ebool isday = dayMapping[msg.sender].eq(dayNow);
        ebool ismonth = monthMapping[msg.sender].eq(monthNow);
        FHE.req(isday);
        FHE.req(ismonth);
        _mint(msg.sender, 100*10**18);
    }

    // check if you are above 65 years old, if yes can mint 10 tokens
    function mint_ifOver65() public {
        // check age year
        uint16 year = getYear(block.timestamp);
        euint16 yearNow = FHE.asEuint16(year);
        ebool isover65 = yearNow.gt(yearMapping[msg.sender].add(FHE.asEuint16(65)));
        FHE.req(isover65);
        _mint(msg.sender, 10*10**18);
    }

    // calculate the day and month based on a timestamp
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    // Returns the day and month for a given timestamp
    function getDayAndMonth(uint timestamp) public pure returns (uint8, uint8) {
        _DateTime memory dt = parseTimestamp(timestamp);
        return (dt.day, dt.month);
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;
        uint YEAR_IN_SECONDS = 31536000;
        uint LEAP_YEAR_IN_SECONDS = 31622400;
        uint DAY_IN_SECONDS = 86400;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(1970);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - 1970 - buf);

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(dt.year)) {
            monthDayCounts[1] = 29;
        } else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i <= 12; i++) {
            buf = YEAR_IN_SECONDS / 12 * i;
            if (secondsAccountedFor + buf > timestamp) {
                dt.month = i;
                buf = YEAR_IN_SECONDS / 12 * (i - 1);
                secondsAccountedFor += buf;
                break;
            }
        }

        // Day
        for (i = 1; i <= monthDayCounts[dt.month - 1]; i++) {
            if (secondsAccountedFor + DAY_IN_SECONDS > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
    }

    function leapYearsBefore(uint year) internal pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function isLeapYear(uint year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function getYear(uint timestamp) internal pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;
        uint YEAR_IN_SECONDS = 31536000;
        uint LEAP_YEAR_IN_SECONDS = 31622400;

        // Year
        year = uint16(1970 + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(1970);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - 1970 - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }


}
