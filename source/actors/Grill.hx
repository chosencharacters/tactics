package actors;

class Grill extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		loadAllFromAnimationSet("girl");
	}
}
