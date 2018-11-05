import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View, TouchableOpacity} from 'react-native';

// Dont forget to add any of these 

import { NativeModules } from 'react-native';
import RNMobileRTC from 'react-native-zoom-sdk';
const { UserType } = RNMobileRTC;
var ZoomSDK = NativeModules.ZoomSDK;

const DEFAULT_MEETING_OPTIONS = {
  meetingNumber: '8611627639',   // your meeting number which you get from your zoom account
  pwd: '',
  participantId: '',
  userName: 'smartdata',
};

export default class App extends Component{

  componentDidMount(){
    // please initialised this before starting any meeting
    RNMobileRTC.initialize('743INReT2TVjDkDE07z3RumHA2tiGR8SZlEV', '1vqi3LemtXMqXONRwBPBQT8850H8qRweVFoL', 'zoom.us')
    .then((result) => {console.log(result, "zoom sdk initialized")})
     .catch((error) => { throw new Error(error.message), console.log(error, "initialized error") });
  }

  onStartMeeting = () => {

    // form android
    if(Platform.OS==='android'){
      RNMobileRTC.joinMeeting({
        meetingNumber: DEFAULT_MEETING_OPTIONS.meetingNumber,
        userName: DEFAULT_MEETING_OPTIONS.userName,
        userType: RNMobileRTC.UserType.ZOOM_USER
      }).then((result) => { console.log(result)})
        .catch((error) => { throw new Error(error.message), console.log(error, "start error")  });
     }

     //for ios
    else{
      ZoomSDK.onJoinaMeeting(DEFAULT_MEETING_OPTIONS.meetingNumber, '', '')
          .then((result) => {console.log(result, "meeting started") })
          .catch((error) => { throw new Error(error.message), console.log(error, "start error")  });
        }
      }

  render() {
    return (
    <View style={{alignItems: "center", justifyContent: "center", flex: 1}}>
      <Text style={{color: "green"}}>Welcome to React Native Zoom!</Text>
      <TouchableOpacity onPress={this.onStartMeeting}>
        <Text>Start zoom meeting</Text>
      </TouchableOpacity>
    </View>);
  }
}

