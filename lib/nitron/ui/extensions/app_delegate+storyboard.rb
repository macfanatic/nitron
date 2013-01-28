module Nitron::AppDelegateStoryboard
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    super
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    if storyboard
      @window.rootViewController = storyboard.instantiateInitialViewController
    end

    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible

    true
  end

  def storyboard
    @storyboard ||= UIStoryboard.storyboardWithName("MainStoryboard", bundle:nil)
  end
end