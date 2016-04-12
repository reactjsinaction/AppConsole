using Swifter
using Base.Test

if VERSION.minor < 5
    macro testset(name, block)
        println(name)
        eval(block)
    end
end


vc = initial("http://localhost:8080")


@testset "View Controller" begin

@test 320 == @query vc.view.frame.size.width

@query vc.label.text = "Hello world"
@test "Hello world" == @query vc.label.text

@query vc.label.alpha = 0.5
@test 0.5 == @query vc.label.alpha

@test false == @query vc.label.userInteractionEnabled

@test 3 == @query vc.view.subviews.count

end



@testset "Application" begin

@test 320 == @query UIApplication.sharedApplication().delegate.window.frame.size.width

end


@testset "Bundle" begin

@test "1" == @query NSBundle.mainBundle.infoDictionary["CFBundleVersion"]
@test "6.0" == @query NSBundle.mainBundle.infoDictionary["CFBundleInfoDictionaryVersion"]
@test ["iPhoneSimulator"] == @query NSBundle.mainBundle.infoDictionary["CFBundleSupportedPlatforms"]
@test "BuildMachineOSBuild" == @query NSBundle.mainBundle.infoDictionary.keys.sort.first
@test "UISupportedInterfaceOrientations" == @query NSBundle.mainBundle.infoDictionary.keys.sort.last

end
