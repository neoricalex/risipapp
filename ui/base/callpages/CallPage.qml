/***********************************************************************************
**    Copyright (C) 2016  Petref Saraci
**    http://risip.io
**
**    This program is free software: you can redistribute it and/or modify
**    it under the terms of the GNU General Public License as published by
**    the Free Software Foundation, either version 3 of the License, or
**    (at your option) any later version.
**
**    This program is distributed in the hope that it will be useful,
**    but WITHOUT ANY WARRANTY; without even the implied warranty of
**    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**    GNU General Public License for more details.
**
**    You have received a copy of the GNU General Public License
**    along with this program. See LICENSE.GPLv3
**    A copy of the license can be found also here <http://www.gnu.org/licenses/>.
**
************************************************************************************/

import QtQuick 2.7

import "../risipcomponents"
import Risip 1.0

CallPageForm {
    id: callPage;
    visible: false

    property RisipCall activeCall

    callDurationLabel.text: stopWatch.elapsedTimeText;

    answerCallButton.onClicked: activeCall.answer();
    endCallButton.onClicked: activeCall.hangup();

    micButton.onCheckedChanged: {
        if(micButton.checked)
            activeCall.media.micVolume = 0.0;
        else
            activeCall.media.micVolume = 1.0;
    }

    RisipTimer {
        id: stopWatch
    }

    Connections {
        target: RisipCallManager

        onIncomingCall: {
            callPage.activeCall = call;
            callPage.state = "incoming";
            callStatusChangeHandler(callPage.activeCall.status)
            callPage.usernameLabel.text = callPage.activeCall.buddy.contact
        }

        onOutgoingCall: {
            callPage.activeCall = call;
            callPage.state = "outgoing"
            callStatusChangeHandler(callPage.activeCall.status);
            callPage.usernameLabel.text = callPage.activeCall.buddy.contact
        }
    }

    Connections {
        target: activeCall

        onErrorCodeChanged: {
            console.log("CALL ERROR NOW : " + code);
            statusLabel.text = "...";
            callPage.visible = false;
        }
        onStatusChanged: { callStatusChangeHandler(activeCall.status) }
    }

    function callStatusChangeHandler(status) {
        console.log("CALL STATUS: " + status);

        switch (status) {
        case RisipCall.CallConfirmed:
            statusLabel.text = "Connected!";
            callPage.state = "incall";
            callPage.visible = true;
            stopWatch.start();
            break;
        case RisipCall.CallDisconnected:
            statusLabel.text = "Disconnected";
            callPage.visible = false;
            stopWatch.reset();
            stopWatch.stop();
            break;
        case RisipCall.CallEarly:
            statusLabel.text = "Ringing..";
            callPage.visible = true;
            break;
        case RisipCall.ConnectingToCall:
            statusLabel.text = "Connecting..";
            callPage.visible = true;
            break;
        case RisipCall.IncomingCallStarted:
            statusLabel.text = "Incoming call!"
            callPage.visible = true;
            break;
        case RisipCall.OutgoingCallStarted:
            statusLabel.text = "Calling.."
            callPage.visible = true;
            break;
        case RisipCall.Null:
            statusLabel.text = "...";
            callPage.visible = false;
            stopWatch.reset();
            stopWatch.stop();
            break;
        }
    }
}
