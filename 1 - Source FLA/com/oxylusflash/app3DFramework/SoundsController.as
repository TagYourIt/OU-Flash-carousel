package com.oxylusflash.app3DFramework 
{
	import com.oxylusflash.utils.StringUtil;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class SoundsController implements IDestroyable
	{
		private var soundInstances:Object;
		private var soundTransform:SoundTransform;
		
		private var _destroyed:Boolean = false;
		
		/**
		 * Sounds controller.
		 * @param	volume	Sounds volume.
		 */
		public function SoundsController(volume:Number = 1) 
		{
			volume = Math.max(0, Math.min(1, volume));
			if (volume) 
			{
				soundTransform = new SoundTransform(volume);
				soundInstances = { };
			}
		}
		
		/**
		 * Add sound.
		 * @param	id		Sound id.
		 * @param	source	Sound source.
		 */
		public function addSound(id:String, source:String):void
		{
			if (soundTransform && !StringUtil.isBlank(source))
			{
				soundInstances[id] = { };
				soundInstances[id].sound = new Sound(new URLRequest(source));
			}
		}
		
		/**
		 * Play sound.
		 * @param	id	Sound id.
		 */
		public function playSound(id:String):void
		{
			if (soundTransform && soundInstances[id])
			{
				var channel:SoundChannel = soundInstances[id].channel;
				if (channel)
				{
					channel.removeEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler);
					channel.stop();
				}
				channel = Sound(soundInstances[id].sound).play(0, 0, soundTransform);
				channel.addEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler, false, 0, true);
				soundInstances[id].channel = channel;
			}
		}
		
		/**
		 * Sound complete
		 */
		private function channel_soundCompleteHandler(e:Event):void 
		{
			var channel:SoundChannel = e.currentTarget as SoundChannel;
			channel.removeEventListener(Event.SOUND_COMPLETE, channel_soundCompleteHandler);
			channel.stop();
			for each(var sndInst:Object in soundInstances)
			{
				if (sndInst.channel == channel)
				{
					delete sndInst.channel;
					break;
				}
			}
		}
		
		/**
		 * Destroy
		 */
		public function destroy():void
		{
			if (soundTransform) 
			{
				soundTransform = null;
				var channel:SoundChannel;
				for (var id:String in soundInstances)
				{
					channel = soundInstances[id].channel as SoundChannel;
					if (channel) channel.stop();
					try { Sound(soundInstances[id].sound).close(); } catch (err:Error) { }
					delete soundInstances[id].sound;
					delete soundInstances[id].channel;
					delete soundInstances[id];
				}
				soundInstances = null;
			}			
			_destroyed = true;
		}
		
		/**
		 * Destroyed
		 */
		public function get destroyed():Boolean { return _destroyed; }
		
	}

}