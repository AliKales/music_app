package com.caroby.caroby_share_your_music;

import io.flutter.embedding.android.FlutterActivity;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.Environment;

import java.io.IOException;
import java.time.Duration;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "caroby/audioRecorder";
    private MediaRecorder mRecorder;

    // creating a variable for mediaplayer class
    private MediaPlayer mPlayer;

    // string variable is created for storing a file name
    private static String mFileName = null;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("startRecording")) {
                                mFileName = getExternalCacheDir().getAbsolutePath();
                                mFileName += "/AudioRecording.m4a";
                                mRecorder = new MediaRecorder();

                                // below method is used to set the audio
                                // source which we are using a mic.
                                mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);

                                // below method is used to set
                                // the output format of the audio.
                                mRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);

                                // below method is used to set the
                                // audio encoder for our recorded audio.
                                mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

                                mRecorder.setAudioChannels(1);
                                mRecorder.setAudioSamplingRate(44100);
                                mRecorder.setAudioEncodingBitRate(96000);

                                // below method is used to set the
                                // output file location for our recorded audio
                                mRecorder.setOutputFile(mFileName);

                                try {
                                    // below mwthod will prepare
                                    // our audio recorder class
                                    mRecorder.prepare();

                                    mRecorder.start();

                                    result.success(mFileName);
                                } catch (IOException e) {
                                    result.error("prepare-error","Recorder can't get prepared",null);
                                }

                            }else if(call.method.equals("stopRecording")){
                                mRecorder.stop();

                                // below method will release
                                // the media recorder class.
                                mRecorder.release();
                                mRecorder = null;

                                result.success("Recording has done");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }


}
