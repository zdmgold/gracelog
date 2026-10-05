package com.gracelog.app

import com.ryanheise.audioservice.AudioServiceFragmentActivity

// AudioServiceFragmentActivity: required for background audio (Sleep
// Sounds) and, being a FragmentActivity, also what biometric auth needs.
class MainActivity : AudioServiceFragmentActivity()
