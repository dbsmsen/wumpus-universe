package com.dbsmsen.wumpusuniverse

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

    private fun updateProgress(progress: Int) {
        runOnUiThread {
            progressBar?.progress = progress
            percentText?.text = "$progress%"
        }
    }

    private fun createLoadingView(): View {
        val layout = RelativeLayout(this)
        layout.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        layout.setBackgroundColor(0xFF2D2D2D.toInt()) // Dark background

        val progressBarWrapper = RelativeLayout(this)
        val wrapperParams = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        wrapperParams.addRule(RelativeLayout.CENTER_IN_PARENT)
        layout.addView(progressBarWrapper, wrapperParams)

        // Add ProgressBar
        progressBar = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal)
        val progressParams = RelativeLayout.LayoutParams(
            dpToPx(200), // 200dp width
            dpToPx(4)    // 4dp height
        )
        progressBar?.id = View.generateViewId()
        progressBar?.max = 100
        progressBar?.progress = 0
        progressBarWrapper.addView(progressBar, progressParams)

        // Add percentage text
        percentText = TextView(this)
        val textParams = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        textParams.addRule(RelativeLayout.BELOW, progressBar?.id ?: 0)
        textParams.topMargin = dpToPx(8)
        percentText?.text = "0%"
        percentText?.setTextColor(0xFFFFFFFF.toInt()) // White text
        progressBarWrapper.addView(percentText, textParams)

        return layout
    }

    private fun dpToPx(dp: Int): Int {
        val density = resources.displayMetrics.density
        return (dp * density).toInt()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        loadingView = createLoadingView()
        addContentView(loadingView, 
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
    }
}
