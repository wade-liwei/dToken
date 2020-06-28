// guard.sol -- simple whitelist implementation of DSAuthority

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.5.12;

import "./DSAuth.sol";

contract DSGuardEvents {
    event LogPermit(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );

    event LogForbid(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );
}

contract DSGuard is DSAuth, DSAuthority, DSGuardEvents {
    bytes32 public constant ANY = bytes32(uint256(-1));

    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bool))) acl;

    function canCall(
        address src_,
        address dst_,
        bytes4 sig
    ) public view returns (bool) {
        bytes32 src = bytes32(bytes20(src_));
        bytes32 dst = bytes32(bytes20(dst_));

        return
            acl[src][dst][sig] ||
            acl[src][dst][ANY] ||
            acl[src][ANY][sig] ||
            acl[src][ANY][ANY] ||
            acl[ANY][dst][sig] ||
            acl[ANY][dst][ANY] ||
            acl[ANY][ANY][sig] ||
            acl[ANY][ANY][ANY];
    }

    function permit(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public auth {
        acl[src][dst][sig] = true;
        emit LogPermit(src, dst, sig);
    }

    function forbid(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public auth {
        acl[src][dst][sig] = false;
        emit LogForbid(src, dst, sig);
    }

    function permit(
        address src,
        address dst,
        bytes32 sig
    ) public auth {
        permit(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);
    }

    function permitx(address src, address dst) public auth {
        permit(bytes32(bytes20(src)), bytes32(bytes20(dst)), ANY);
    }

    function forbid(
        address src,
        address dst,
        bytes32 sig
    ) public auth {
        forbid(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);
    }

    function forbidx(address src, address dst) public auth {
        forbid(bytes32(bytes20(src)), bytes32(bytes20(dst)), ANY);
    }
}