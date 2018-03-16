import Darwin

if let factory = OneTimePasswordFactory(sharedSecret: "please send your answer to big pig care of the funny farm") {
    let password = factory.generate();
    print("\(password)")
}
