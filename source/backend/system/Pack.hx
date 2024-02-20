package backend.system;

@:structInit class Pack {
  public var name: String = "Friday Night Funkin'";
  public var desc: String = "Cartoon Rhythm-game excellence!";
  public var version: String = "0.2.8";

  public function toString()
    return '[PACK INFO]: [ Name: $name | Description: $desc | Version: $version ]';
}
