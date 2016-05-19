package fairygui {
	import laya.utils.Handler;
	import laya.utils.Tween;
    
    public class GearSize extends GearBase {
        private var _storage: Object;
        private var _default: GearSizeValue;
        private var _tweenValue: GearSizeValue;
        private var _tweener: Tween;

        public function GearSize(owner: GObject) {
            super(owner);
        }
        
		override protected function init(): void {
            this._default = new GearSizeValue(this._owner.width,this._owner.height,
                this._owner.scaleX,this._owner.scaleY);
            this._storage = {};
        }

		override protected function addStatus(pageId: String, value: String): void {
            var arr: Array = value.split(",");
            var gv: GearSizeValue;
            if (pageId == null)
                gv = this._default;
            else {
                gv = new GearSizeValue();
                this._storage[pageId] = gv;
            }
            gv.width = parseInt(arr[0]);
            gv.height = parseInt(arr[1]);
            if(arr.length>2)
            {
                gv.scaleX = parseFloat(arr[2]);
                gv.scaleY = parseFloat(arr[3]);
            }
        }

		override public function apply(): void {
            var gv: GearSizeValue;
            var ct: Boolean = this.connected;
            if (ct) {
                gv = this._storage[this._controller.selectedPageId];
                if (!gv)
                    gv = this._default;
            }
            else
                gv = this._default;
                
            if(this._tweener)
                this._tweener.complete();
                
            if(this._tween && !UIPackage._constructing && !GearBase.disableAllTweenEffect
                && ct && this._pageSet.containsId(this._controller.previousPageId)) {
                var a: Boolean = gv.width != this._owner.width || gv.height != this._owner.height;
                var b: Boolean = gv.scaleX != this._owner.scaleX || gv.scaleY != this._owner.scaleY;
                if(a || b) {
                    this._owner.internalVisible++;
                    if(this._tweenValue == null)
                        this._tweenValue = new GearSizeValue();
                    this._tweenValue.width = this._owner.width;
                    this._tweenValue.height = this._owner.height;
                    this._tweenValue.scaleX = this._owner.scaleX;
                    this._tweenValue.scaleY = this._owner.scaleY;
                    this._tweener = Tween.to(this._tweenValue, 
                        { width: gv.width, height: gv.height, scaleX: gv.scaleX, scaleY: gv.scaleY }, 
                        this._tweenTime*1000, 
                        this._easeType,
                        Handler.create(this, this.__tweenComplete),
                        this._delay*1000);
                    this._tweener.update = Handler.create(this, this.__tweenUpdate, [a,b], false);
                }
            }
            else {
                this._owner._gearLocked = true;
                this._owner.setSize(gv.width,gv.height,this._owner.gearXY.controller == this._controller);
                this._owner.setScale(gv.scaleX,gv.scaleY);
                this._owner._gearLocked = false;
            }
        }
        
        private function __tweenUpdate(a:Boolean, b:Boolean):void {
            this._owner._gearLocked = true;
            if(a)
                this._owner.setSize(this._tweenValue.width,this._tweenValue.height,this._owner.gearXY.controller == this._controller);
            if(b)
                this._owner.setScale(this._tweenValue.scaleX,this._tweenValue.scaleY);
            this._owner._gearLocked = false;
        }
        
        private function __tweenComplete():void {
            this._owner.internalVisible--;
            this._tweener = null;
        }

		override public function updateState(): void {
            if (this._owner._gearLocked)
                return;

            var gv: GearSizeValue;
            if (this.connected) {
                gv = this._storage[this._controller.selectedPageId];
                if(!gv) {
                    gv = new GearSizeValue();
                    this._storage[this._controller.selectedPageId] = gv;
                }
            }
            else {
                gv = this._default;
            }

            gv.width = this._owner.width;
            gv.height = this._owner.height;
            gv.scaleX = this._owner.scaleX;
            gv.scaleY = this._owner.scaleY;
        }
        
        public function updateFromRelations(dx: Number,dy: Number): void {
            for(var key:String in this._storage) {
                var gv: GearSizeValue = this._storage[key];
                gv.width += dx;
                gv.height += dy;
            }
            this._default.width += dx;
            this._default.height += dy;

            this.updateState();
        }
    }
}

class GearSizeValue
{
	public var width:Number;
	public var height:Number;
	public var scaleX:Number;
	public var scaleY:Number;
	
	public function GearSizeValue(width:Number=0, height:Number=0, scaleX:Number=0, scaleY:Number=0)
	{
		this.width = width;
		this.height = height;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
	}
}