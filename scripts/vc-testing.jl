# open Demo/ViewController/ViewController.xcworkspace
# Run

using Swifter
using Base.Test

if VERSION < v"0.5-" @eval begin
    macro testset(name, block)
        println(name)
        eval(block)
    end
end end


vc = initial("http://localhost:8080")


@testset "View Controller" begin

    @test 320 == @query vc.view.frame.size.width

    @query vc.label.text = "Hello world"
    @test "Hello world" == @query vc.label.text
    @test "Hello world" == @query vc.view.subviews[0].text

    @query vc.label.alpha = 0.5
    @test 0.5 == @query vc.label.alpha
    @test 0.5 == @query vc.view.subviews[0].alpha

    @query vc.label.alpha = 1
    @test 1 == @query vc.label.alpha
    @test 1 == @query vc.view.subviews[0].alpha

    @query vc.label.userInteractionEnabled = false
    @test false == @query vc.label.userInteractionEnabled
    @test false == @query vc.view.subviews[0].userInteractionEnabled

    @query vc.label.userInteractionEnabled = true
    @test true == @query vc.label.userInteractionEnabled
    @test true == @query vc.view.subviews[0].userInteractionEnabled

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
    @test AbstractString["iPhoneSimulator"] == @query NSBundle.mainBundle.infoDictionary["CFBundleSupportedPlatforms"]
    @test "BuildMachineOSBuild" == @query NSBundle.mainBundle.infoDictionary.keys.sort.first
    @test "UISupportedInterfaceOrientations" == @query NSBundle.mainBundle.infoDictionary.keys.sort.last
    
    @query NSBundle.mainBundle.bundleIdentifier
    @test "com.factor.ViewController" == @query NSBundle.mainBundle.infoDictionary["CFBundleIdentifier"]
    @query NSBundle.mainBundle.infoDictionary.keys
    @query NSBundle.mainBundle.infoDictionary.keys.sort
    @query NSBundle.mainBundle.infoDictionary.keys[0]
    @query NSBundle.mainBundle.infoDictionary.keys[1]
    @query NSBundle.mainBundle.infoDictionary.values

end
