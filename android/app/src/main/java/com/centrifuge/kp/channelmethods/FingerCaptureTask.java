package com.centrifuge.kp.channelmethods;

import android.app.Activity;
import android.util.Log;

import com.neurotec.biometrics.NBiometricStatus;
import com.neurotec.biometrics.NFinger;
import com.neurotec.biometrics.NSubject;
import com.neurotec.biometrics.NTemplateSize;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.devices.NDeviceManager;
import com.neurotec.devices.NDeviceType;
import com.neurotec.io.NFile;
import com.neurotec.samples.util.FileUtils;
import com.neurotec.util.concurrent.CompletionHandler;

import java.io.File;
import java.io.IOException;

import android.util.Base64;

import java.util.EnumSet;
import java.util.UUID;

import io.flutter.plugin.common.MethodChannel;

public class FingerCaptureTask implements Runnable {
    public static  NSubject subject;
    public static NBiometricClient mBiometricClient;
    
    MethodChannel.Result result;
    Activity activity;
    FingerCaptureTaskProgress fingerCaptureTaskProgress;
    int index;

    public FingerCaptureTask(Activity activity,FingerCaptureTaskProgress fingerCaptureTaskProgress,int index,MethodChannel.Result result) {
        this.result = result;
        this.activity = activity;
        this.index=index;
        this.fingerCaptureTaskProgress=fingerCaptureTaskProgress;
        if(mBiometricClient==null){
            mBiometricClient = new NBiometricClient();
            mBiometricClient.setUseDeviceManager(true);
            mBiometricClient.getDeviceManager().setDeviceTypes(EnumSet.of(NDeviceType.FINGER_SCANNER));
            mBiometricClient.setFingersTemplateSize(NTemplateSize.LARGE);
            mBiometricClient.initialize();
        }
    }

    @Override
    public void run() {
        try {
            if(subject==null){
                subject = new NSubject();
            }
            NFinger finger = new NFinger();

            NDeviceManager deviceManager = mBiometricClient.getDeviceManager();
            NDeviceManager.DeviceCollection devices = deviceManager.getDevices();
            if (devices.size() > 0) {
                Log.i("CAPTURE_TASK", "Found " + devices.size() + " fingerprint scanner");
            } else {
                Log.i("CAPTURE_TASK", "No Scanners found");
//                mBiometricClient.cancel();
                activity.runOnUiThread(() -> result.success(null));
                return;
            }

            if(fingerCaptureTaskProgress==FingerCaptureTaskProgress.RECAPTURE){
                subject.getFingers().remove(index);
            }
//            subject.getFingers().add(finger);
            Log.i("INDEX", String.valueOf(index));
            subject.getFingers().add(index,finger);

            Log.i("CAPTURE_TASK", "Capturing");
            mBiometricClient.createTemplate(subject, subject, completionHandler);
        } catch (Exception e) {
            Log.e("CAPTURE_TASK", e.toString());
//            mBiometricClient.cancel();
            activity.runOnUiThread(() -> result.success(null));
        }
    }

    private CompletionHandler<NBiometricStatus, NSubject> completionHandler = new CompletionHandler<NBiometricStatus, NSubject>() {
        @Override
        public void completed(NBiometricStatus biometricResult, NSubject subject) {
            if (biometricResult == NBiometricStatus.OK) {
                String id = UUID.randomUUID().toString();
                Log.i("CAPTURE_TASK", "Template created");

                File fileOutput = new File(activity.getApplicationContext().getCacheDir(), id + ".jpeg");
                try {
                    subject.getFingers().get(index).getImage().save(fileOutput.getAbsolutePath());
//                    byte[] isoTemplate = subject.getTemplateBuffer(CBEFFBiometricOrganizations.ISO_IEC_JTC_1_SC_37_BIOMETRICS, CBEFFBDBFormatIdentifiers.ISO_IEC_JTC_1_SC_37_BIOMETRICS_FINGER_MINUTIAE_RECORD_FORMAT, FMRecord.VERSION_ISO_CURRENT).toByteArray();
                } catch (Exception e) {
                    Log.e("CAPTURE_TASK", e.toString());
                }

//                File fileOutput2 = new File(new File("/storage/emulated/0/Neurotechnology"), id + ".dat");
//                try {
//                    NFile.writeAllBytes(fileOutput2.getAbsolutePath(), subject.getTemplateBuffer());
//                } catch (Exception e) {
//                    Log.e("ERROR",e.getMessage());
//                }

//                if(fingerCaptureTaskProgress==FingerCaptureTaskProgress.LAST){
//                    mBiometricClient.cancel();
//                }

                try {
                    byte[] fileContent = FileUtils.readFileToByteArray(fileOutput.getAbsolutePath());
                    String encodedString = Base64.encodeToString(fileContent, Base64.DEFAULT);
                    activity.runOnUiThread(() -> result.success(encodedString));
                } catch (IOException e) {
                    activity.runOnUiThread(() -> result.success(null));
                }
            } else {
                Log.i("CAPTURE_TASK", "Template not created");
                activity.runOnUiThread(() -> result.success(null));
            }
        }

        @Override
        public void failed(Throwable exc, NSubject subject) {
            exc.printStackTrace();
        }
    };
}

