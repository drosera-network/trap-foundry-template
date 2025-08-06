pragma solidity ^0.8.12;

struct EventLog {
    // The topics of the log, including the signature, if any.
    bytes32[] topics;
    // The raw data of the log.
    bytes data;
    // The address of the log's emitter.
    address emitter;
}

struct EventFilter {
    // The address of the contract to filter logs from.
    address contractAddress;
    // The topics to filter logs by.
    string signature;
}

library EventFilterLib {
    /**
     * @notice Computes the topic0 for the given EventFilter.
     * @param filter The EventFilter to compute the topic0 for.
     * @return The computed topic0 as bytes32.
     */
    function topic0(EventFilter memory filter) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(filter.signature));
    }

    /**
     * @notice Checks if a log matches the given filter.
     * @param filter The EventFilter to match against.
     * @param log The EventLog to check.
     * @return True if the log matches the filter, false otherwise.
     */
    function matches(
        EventFilter memory filter,
        EventLog memory log
    ) internal pure returns (bool) {
        // Check if the log's emitter matches the filter's contract address
        if (log.emitter != filter.contractAddress) {
            return false;
        }

        // Check if the first topic of the log matches the filter's topic0
        if (log.topics.length == 0 || log.topics[0] != topic0(filter)) {
            return false;
        }

        return true;
    }
}

abstract contract Trap {
    EventLog[] private eventLogs;

    /**
     * @notice Collects data from the trap.
     * @return The collected data as bytes.
     */
    function collect() external view virtual returns (bytes memory);

    /**
     * @notice Determines if the trap should respond based on the provided data.
     * @param data The data to evaluate.
     * @return A tuple containing a boolean indicating if a response is needed and the response data.
     */
    function shouldRespond(
        bytes[] calldata data
    ) external pure virtual returns (bool, bytes memory);


    /**
     * @notice Returns the event log filters for the trap.
     * @return An array of EventFilter objects.
     */
    function eventLogFilters() public view virtual returns (EventFilter[] memory) {
        EventFilter[] memory filters = new EventFilter[](0);
        return filters;
    }

    /**
     * @notice Returns the version of the Trap.
     * @return The version as a string.
     */
    function version() public pure returns (string memory) {
        return "2.0";
    }

    /**
     * @notice Sets the event logs in the trap.
     * @param logs An array of EventLog objects to set.
     */
    function setEventLogs(EventLog[] calldata logs) public {
       EventLog[] storage storageArray = eventLogs;
      
        // Set new logs
        for (uint256 i = 0; i < logs.length; i++) {
            storageArray.push(EventLog({
                emitter: logs[i].emitter,
                topics: logs[i].topics,
                data: logs[i].data
            }));
        }
    }


    /**
     * @notice Gets the event logs stored in the trap.
     * @return An array of EventLog objects.
     */ 
    function getEventLogs() public view returns (EventLog[] memory) {
        EventLog[] storage storageArray = eventLogs;
        EventLog[] memory logs = new EventLog[](storageArray.length);

        for (uint256 i = 0; i < storageArray.length; i++) {
            logs[i] = EventLog({
                emitter: storageArray[i].emitter,
                topics: storageArray[i].topics,
                data: storageArray[i].data
            });
        }
        return logs;
    }
}
