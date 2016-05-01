# open Demo/ViewController/ViewController.xcworkspace
# Run

using Swifter
using Base.Test

if VERSION < v"0.5-" @eval begin
    print_with_color(:red, "recommend to use Julia 0.5")
    macro testset(name, block)
    end
end end


vc = initial("http://localhost:8080")


@testset "View Controller" begin

    @test 320 == @query vc.view.frame.size.width
    
    @query vc.label.text = "Hello world"
    @test "Hello world" == @query vc.label.text
    
    @query vc.label.alpha = 0.5
    @test 0.5 == @query vc.label.alpha
    @query vc.label.alpha = 1
    
    @test false == @query vc.label.userInteractionEnabled
    
    @test 3 == @query vc.view.subviews.count

end



@testset "Application" begin

    @test 320 == @query UIApplication.sharedApplication().delegate.window.frame.size.width
    @query UIApplication.sharedApplication().delegate
    @query UIApplication.sharedApplication().delegate.window
    @query UIApplication.sharedApplication().keyWindow
    @query UIApplication.sharedApplication().windows
    @query UIApplication.sharedApplication().backgroundTimeRemaining

end



@testset "Bundle" begin

    @test "1" == @query NSBundle.mainBundle.infoDictionary["CFBundleVersion"]
    @test "6.0" == @query NSBundle.mainBundle.infoDictionary["CFBundleInfoDictionaryVersion"]
    @test ["iPhoneSimulator"] == @query NSBundle.mainBundle.infoDictionary["CFBundleSupportedPlatforms"]
    @test "BuildMachineOSBuild" == @query NSBundle.mainBundle.infoDictionary.keys.sort.first
    @test "UISupportedInterfaceOrientations" == @query NSBundle.mainBundle.infoDictionary.keys.sort.last
    
    @query NSBundle.mainBundle.bundleIdentifier
    @query NSBundle.mainBundle.infoDictionary["CFBundleIdentifier"]
    @query NSBundle.mainBundle.infoDictionary.keys
    @query NSBundle.mainBundle.infoDictionary.keys.sort
    @query NSBundle.mainBundle.infoDictionary.keys[0]
    @query NSBundle.mainBundle.infoDictionary.keys[1]
    @query NSBundle.mainBundle.infoDictionary.values

end
