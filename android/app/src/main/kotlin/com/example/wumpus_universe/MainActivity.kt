package com.example.wumpus_universe

import android.os.Bundle
import android.widget.ProgressBar
import android.widget.TextView
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var loadingView: View? = null
    private var progressBar: ProgressBar? = null
    private var percentText: TextView? = null
    private val CHANNEL = "wumpus_universe/loading"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateProgress") {
                val progress = call.argument<Int>("progress") ?: 0
                updateProgress(progress)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
    
    override fun onPostResume() {
        super.onPostResume()
        
        // Add loading view after Flutter view is created
        if (loadingView == null) {
            try {
                // Inflate loading view
                loadingView = layoutInflater.inflate(
                    resources.getIdentifier("launch_screen", "layout", packageName),
                    null
                )
                
                // Get views
                progressBar = loadingView?.findViewById(
                    resources.getIdentifier("loadingProgressBar", "id", packageName)
                )
                
                percentText = loadingView?.findViewById(
                    resources.getIdentifier("loadingPercentText", "id", packageName)
                )
                
                // Add to root view
                val rootView = findViewById<ViewGroup>(android.R.id.content)
                if (rootView != null && rootView.childCount > 0) {
                    rootView.addView(loadingView, 
                        RelativeLayout.LayoutParams(
                            RelativeLayout.LayoutParams.MATCH_PARENT,
                            RelativeLayout.LayoutParams.MATCH_PARENT
                        )
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    // Update progress bar
    private fun updateProgress(progress: Int) {
        runOnUiThread {
            try {
                progressBar?.progress = progress
                percentText?.text = "$progress%"
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    // Remove loading view when Flutter UI is displayed
    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        
        runOnUiThread {
            try {
                loadingView?.animate()
                    ?.alpha(0f)
                    ?.setDuration(500)
                    ?.withEndAction {
                        val rootView = findViewById<ViewGroup>(android.R.id.content)
                        rootView?.removeView(loadingView)
                        loadingView = null
                        progressBar = null
                        percentText = null
                    }
                    ?.start()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
