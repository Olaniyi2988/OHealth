package com.centrifuge.kp;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.util.Base64;
import android.util.Log;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import com.centrifuge.kp.channelmethods.FingerCaptureTask;
import com.centrifuge.kp.channelmethods.FingerCaptureTaskProgress;
import com.neurotec.biometrics.NBiometricStatus;
import com.neurotec.biometrics.NFinger;
import com.neurotec.biometrics.NMatchingSpeed;
import com.neurotec.biometrics.NSubject;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.images.NImage;
import com.neurotec.io.NFile;
import com.neurotec.lang.NCore;
import com.neurotec.licensing.NLicenseManager;
import com.neurotec.licensing.gui.ActivationActivity;
import com.neurotec.licensing.gui.LicensingPreferencesFragment;
import com.neurotec.plugins.NDataFileManager;
import com.neurotec.samples.licensing.LicensingManager;
import com.neurotec.samples.util.FileUtils;
import com.neurotec.samples.util.NImageUtils;
import com.neurotec.util.concurrent.CompletionHandler;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "kp.centrifugegroup/scanner";
    private static final String[] LICENSES = new String[]{"FingerClient","FingerMatcher"};

    private MethodChannel.Result pendingMethodChannelResult;

    ActivityResultLauncher<Intent> allFilesPermissionLauncher;

    @Override
    protected void onCreate(Bundle savedInstanceBundle) {
        super.onCreate(savedInstanceBundle);
        try {
            allFilesPermissionLauncher = registerForActivityResult(
                    new ActivityResultContracts.StartActivityForResult(),
                    result -> {
                        if (result.getResultCode() == Activity.RESULT_OK) {
                            try {
                                if (Environment.isExternalStorageManager()) {
                                    pendingMethodChannelResult.success(true);
                                } else {
                                    pendingMethodChannelResult.success(false);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                pendingMethodChannelResult.success(false);
                            }
                        }
                    });


            NCore.setContext(this);
            NDataFileManager.getInstance().addFromDirectory("data", false);
            NLicenseManager.setTrialMode(LicensingPreferencesFragment.isUseTrial(this));
            NLicenseManager.getWritableStoragePath();
            System.setProperty("jna.nounpack", "true");
            System.setProperty("java.io.tmpdir", getCacheDir().getAbsolutePath());
        } catch (Exception e) {
            Log.e("MAIN_ACTIVITY", "Exception", e);
        }

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1 && pendingMethodChannelResult != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                if (!Environment.isExternalStorageManager()) {
                    Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                    intent.addCategory(Intent.CATEGORY_DEFAULT);
                    intent.setData(Uri.parse(String.format("package:%s", getApplicationContext().getPackageName())));
                    allFilesPermissionLauncher.launch(intent);
                } else {
                    pendingMethodChannelResult.success(true);
                }
            } else {
                pendingMethodChannelResult.success(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED);
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("obtainLicenses")) {
                                ExecutorService executor = Executors.newFixedThreadPool(1);
                                FutureTask<String> obtainLicenseTask = new FutureTask<>(new CheckLicenseTask(result), "");
                                executor.submit(obtainLicenseTask);
                            } else if (call.method.equals("fingerCaptureTask")) {
                                ExecutorService executor = Executors.newFixedThreadPool(1);
                                FingerCaptureTaskProgress captureTaskProgress = FingerCaptureTaskProgress.FIRST;
                                String progress = call.argument("progress");
                                int index = call.argument("index");
                                if (progress.equals("intermediate")) {
                                    captureTaskProgress = FingerCaptureTaskProgress.INTERMEDIATE;
                                } else if (progress.equals("last")) {
                                    captureTaskProgress = FingerCaptureTaskProgress.LAST;
                                } else if (progress.equals("recapture")) {
                                    captureTaskProgress = FingerCaptureTaskProgress.LAST;
                                }
                                FutureTask<String> fingerCaptureTask = new FutureTask<>(new FingerCaptureTask(this, captureTaskProgress, index, result), "");
                                executor.submit(fingerCaptureTask);
                            }else if (call.method.equals("verificationTask")) {
                                ExecutorService executor = Executors.newFixedThreadPool(1);
                                FutureTask<String> verificationTask = new FutureTask<>(new FingerVerificationTask(result,call), "");
                                executor.submit(verificationTask);
                            } else if (call.method.equals("captureResult")) {
                                String id = UUID.randomUUID().toString();
                                File fileOutput = new File(this.getDataDir(), id + ".dat");
                                try {
                                    NFile.writeAllBytes(fileOutput.getAbsolutePath(), FingerCaptureTask.subject.getTemplateBuffer());
                                    Map<String, Object> map = new HashMap<String, Object>();
                                    map.put("fingers", FingerCaptureTask.subject.getFingers().size());
                                    map.put("filePath", fileOutput.getAbsolutePath());
                                    FingerCaptureTask.subject = null;
                                    result.success(map);
                                } catch (IOException e) {
                                    result.success(null);
                                }
                            } else if (call.method.equals("bioPermissionCheck")) {
                                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) ==
                                        PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                                        PackageManager.PERMISSION_GRANTED) {
                                    result.success(true);
                                } else {
                                    result.success(false);
                                }
                            } else if (call.method.equals("bioPermissionRequest")) {
                                try {
                                    String[] permissions;
                                    permissions = new String[]{Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE};
                                    pendingMethodChannelResult = result;
                                    requestPermissions(permissions, 1);
                                } catch (Exception e) {
                                    Log.e("REQUEST", e.getMessage());
                                    result.success(false);
                                }
                            } else if (call.method.equals("licenseManager")) {
                                try {
                                    FileOutputStream fileOutputStream1 = new FileOutputStream(new File(call.argument("clientpath").toString()));
                                    PrintWriter p1 = new PrintWriter(fileOutputStream1);
                                    p1.print(call.argument("matcher").toString());
                                    p1.flush();
                                    p1.close();

                                    FileOutputStream fileOutputStream2 = new FileOutputStream(new File(call.argument("matcherpath").toString()));
                                    PrintWriter p2 = new PrintWriter(fileOutputStream2);
                                    p2.print(call.argument("client").toString());
                                    p2.flush();
                                    p2.close();

                                    startActivity(new Intent(this, ActivationActivity.class));
                                    result.success(true);
                                } catch (Exception e) {
                                    Log.e("LICENSE_TASK", e.toString());
                                    result.success(false);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    final class CheckLicenseTask implements Runnable {
        MethodChannel.Result result;

        CheckLicenseTask(MethodChannel.Result result) {
            this.result = result;
        }

        @Override
        public void run() {
            try {
                List<String> obtainedLicenses = LicensingManager.getInstance()
                        .obtainLicenses(MainActivity.this, LICENSES);
                if (obtainedLicenses.size() == LICENSES.length) {
                    Log.i("LICENSE_TASK", "Licenses obtained");
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            result.success(true);
                        }
                    });
                } else {
                    Log.i("LICENSE_TASK", "Failed to obntain Licenses");
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            result.success(false);
                        }
                    });
                }
            } catch (Exception e) {
                Log.i("LICENSE_TASK", e.toString());
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        result.success(false);
                    }
                });
            }
        }
    }

    final class FingerVerificationTask implements Runnable {
        MethodChannel.Result methodResult;
        MethodCall call;
        NBiometricClient mBiometricClient;

        FingerVerificationTask(MethodChannel.Result result, MethodCall call) {
            this.methodResult = result;
            this.call = call;
        }

        @Override
        public void run() {
            try {

                mBiometricClient = new NBiometricClient();
                // Set matching threshold
                mBiometricClient.setMatchingThreshold(48);
                // Set matching speed
                mBiometricClient.setFingersMatchingSpeed(NMatchingSpeed.LOW);
                // Initialize NBiometricClient
                mBiometricClient.initialize();

                List<String> prints = call.argument("prints");
                String subjectPrint = call.argument("subject");

                NSubject reference = new NSubject();


                for (int x = 0; x < prints.size(); x++) {
                    NFinger finger = new NFinger();
                    finger.setImage(NImageUtils.fromJPEG(Base64.decode(prints.get(x), 0)));
                    reference.getFingers().add(finger);
                }


                NSubject candidate = new NSubject();
                NFinger finger = new NFinger();
                finger.setImage(NImageUtils.fromJPEG(Base64.decode(subjectPrint, 0)));
                candidate.getFingers().add(finger);

                mBiometricClient.verify(reference, candidate, null, new CompletionHandler<NBiometricStatus, Void>() {
                    @Override
                    public void completed(NBiometricStatus result, Void attachment) {
                        if (result == NBiometricStatus.OK || result == NBiometricStatus.MATCH_NOT_FOUND) {
                            int score = reference.getMatchingResults().get(0).getScore();
                            Log.i("SCORE", String.valueOf(score));
                            mBiometricClient.cancel();
                            if (result == NBiometricStatus.OK && score>48) {
                                runOnUiThread(() -> methodResult.success(true));
                            } else {
                                runOnUiThread(() -> methodResult.success(false));
                            }
                        }
                    }

                    @Override
                    public void failed(Throwable throwable, Void unused) {
                        mBiometricClient.cancel();
                        runOnUiThread(() -> methodResult.success(null));
                    }
                });
            } catch (Exception e) {
                mBiometricClient.cancel();
                Log.e("VERIFY_TASK", e.toString());
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        methodResult.success(null);
                    }
                });
            }
        }
    }

}


