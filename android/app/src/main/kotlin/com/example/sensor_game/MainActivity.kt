package com.example.sensor_game

import android.content.BroadcastReceiver
import android.content.Context
<<<<<<< HEAD
import android.content.Intent
import android.content.IntentFilter
=======
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
>>>>>>> 344b71bd82b62bb5ea6d15fcc89fce2ae14bacd1
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
<<<<<<< HEAD

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL_NAME = "com.sensorIO.sensor"
    private val METHOD_CHANNEL_NAME = "com.sensorIO.method"
    private lateinit var sensorManager: SensorManager
    private lateinit var batteryManager: BatteryManager
    private var methodChannel:MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var sensorStreamHandler:StreamHandler? = null
    private lateinit var intent: Intent
   //private var batteryStreamHandler:BatteryStreamHandler? =null

=======
import java.util.stream.Stream
import kotlin.system.exitProcess

class MainActivity: FlutterActivity() {
    private val EVENT_CHANNEL_NAME = "com.sensorIO.sensor" //이벤트기반 채널통신 주소
    private val METHOD_CHANNEL_NAME = "com.sensorIO.method"// 메소드 인보크 기반 주소

    private lateinit var sensorManager: SensorManager //센서 데이터를 불러오기위해 필요함

    private var methodChannel:MethodChannel? = null //메소드 채널용
    private var eventChannel: EventChannel? = null //이벤트 채널용
    private var sensorStreamHandler:StreamHandler? = null //이벤트기반으로 센서데이터를 방송하기위해 필요함


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
>>>>>>> 344b71bd82b62bb5ea6d15fcc89fce2ae14bacd1
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel!!.setMethodCallHandler { call, result ->
            if(call.method == "callPressureSensor"){
                setupChannels(this, flutterEngine.dartExecutor.binaryMessenger, Sensor.TYPE_PRESSURE)
                result.success(1)
            }
            if(call.method == "callTemperatureSensor"){
<<<<<<< HEAD
                val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                var temperature = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 1)
                print(temperature)
                result.success(temperature)
=======
                var res = getBatteryLevel()
                result.success(res)
>>>>>>> 344b71bd82b62bb5ea6d15fcc89fce2ae14bacd1
            }
            if(call.method == "callAccelerometerSensor"){

            }
<<<<<<< HEAD
            else{
                //result.error("404","404",-1)
            }
=======
            if(call.method == "callRotationVectorSensor"){
                setupChannels(this, flutterEngine.dartExecutor.binaryMessenger, Sensor.TYPE_ROTATION_VECTOR)
                result.success(1)
            }else{
                result.success(0)
            }
        }
    }
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
        return batteryLevel
    }

    @RequiresApi(Build.VERSION_CODES.R)
    //5스테이지용
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if(newConfig.isNightModeActive){
            println("config changed")
>>>>>>> 344b71bd82b62bb5ea6d15fcc89fce2ae14bacd1
        }
    }
    private fun setupChannels(context: Context, messenger: BinaryMessenger, SensorType: Int){
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
        sensorStreamHandler = StreamHandler(sensorManager!!, SensorType)
        eventChannel!!.setStreamHandler(sensorStreamHandler)

    }
//    private fun setUpBatteryChannel(context: Context, messenger: BinaryMessenger){
//        eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
//        batteryStreamHandler = BatteryStreamHandler(context)
//        eventChannel!!.setStreamHandler(batteryStreamHandler)
//
//    }

    override fun onDestroy() {
        super.onDestroy()
    }
}


class StreamHandler(private val sensorManager: SensorManager, sensorType: Int,
                    private var interval: Int = SensorManager.SENSOR_DELAY_NORMAL ):EventChannel.StreamHandler, SensorEventListener {
    private val sensor = sensorManager.getDefaultSensor(sensorType)
    private var eventSink:EventChannel.EventSink? = null
    val streamedSensorType = sensorType //플러터로 1개 초과의 데이터를 넘겨줄 필요가 있는 센서타입인지 체크 하는 용도 예)3축 사용 센서들

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if(sensor !=null){
            eventSink = events
            sensorManager.registerListener(this, sensor, interval)
        }

    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        ///센서가 로테이션 벡터의 3축 값을 넘겨주어야 하는지 체크
        if(streamedSensorType == Sensor.TYPE_ROTATION_VECTOR){
            val sensorValues = event!!.values
            eventSink?.success(sensorValues)
        }
        else{
            val sensorValues = event!!.values[0]
            eventSink?.success(sensorValues)
        }

    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy:Int) {

    }
}
