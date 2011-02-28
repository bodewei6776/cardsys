/** jquery.color.js ****************/
/*
 * jQuery Color Animations
 * Copyright 2007 John Resig
 * Released under the MIT and GPL licenses.
 */

(function(jQuery){

	// We override the animation for all of these color styles
	jQuery.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'], function(i,attr){
		jQuery.fx.step[attr] = function(fx){
			if ( fx.state == 0 ) {
				fx.start = getColor( fx.elem, attr );
				fx.end = getRGB( fx.end );
			}
            if ( fx.start )
                fx.elem.style[attr] = "rgb(" + [
                    Math.max(Math.min( parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0]), 255), 0),
                    Math.max(Math.min( parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1]), 255), 0),
                    Math.max(Math.min( parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2]), 255), 0)
                ].join(",") + ")";
		}
	});

	// Color Conversion functions from highlightFade
	// By Blair Mitchelmore
	// http://jquery.offput.ca/highlightFade/

	// Parse strings looking for color tuples [255,255,255]
	function getRGB(color) {
		var result;

		// Check if we're already dealing with an array of colors
		if ( color && color.constructor == Array && color.length == 3 )
			return color;

		// Look for rgb(num,num,num)
		if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
			return [parseInt(result[1]), parseInt(result[2]), parseInt(result[3])];

		// Look for rgb(num%,num%,num%)
		if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
			return [parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];

		// Look for #a0b1c2
		if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
			return [parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];

		// Look for #fff
		if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
			return [parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];

		// Otherwise, we're most likely dealing with a named color
		return colors[jQuery.trim(color).toLowerCase()];
	}
	
	function getColor(elem, attr) {
		var color;

		do {
			color = jQuery.curCSS(elem, attr);

			// Keep going until we find an element that has color, or we hit the body
			if ( color != '' && color != 'transparent' || jQuery.nodeName(elem, "body") )
				break; 

			attr = "backgroundColor";
		} while ( elem = elem.parentNode );

		return getRGB(color);
	};
	
	// Some named colors to work with
	// From Interface by Stefan Petre
	// http://interface.eyecon.ro/

	var colors = {
		aqua:[0,255,255],
		azure:[240,255,255],
		beige:[245,245,220],
		black:[0,0,0],
		blue:[0,0,255],
		brown:[165,42,42],
		cyan:[0,255,255],
		darkblue:[0,0,139],
		darkcyan:[0,139,139],
		darkgrey:[169,169,169],
		darkgreen:[0,100,0],
		darkkhaki:[189,183,107],
		darkmagenta:[139,0,139],
		darkolivegreen:[85,107,47],
		darkorange:[255,140,0],
		darkorchid:[153,50,204],
		darkred:[139,0,0],
		darksalmon:[233,150,122],
		darkviolet:[148,0,211],
		fuchsia:[255,0,255],
		gold:[255,215,0],
		green:[0,128,0],
		indigo:[75,0,130],
		khaki:[240,230,140],
		lightblue:[173,216,230],
		lightcyan:[224,255,255],
		lightgreen:[144,238,144],
		lightgrey:[211,211,211],
		lightpink:[255,182,193],
		lightyellow:[255,255,224],
		lime:[0,255,0],
		magenta:[255,0,255],
		maroon:[128,0,0],
		navy:[0,0,128],
		olive:[128,128,0],
		orange:[255,165,0],
		pink:[255,192,203],
		purple:[128,0,128],
		violet:[128,0,128],
		red:[255,0,0],
		silver:[192,192,192],
		white:[255,255,255],
		yellow:[255,255,0]
	};
	
})(jQuery);

/** jquery.easing.js ****************/
/*
 * jQuery Easing v1.1 - http://gsgd.co.uk/sandbox/jquery.easing.php
 *
 * Uses the built in easing capabilities added in jQuery 1.1
 * to offer multiple easing options
 *
 * Copyright (c) 2007 George Smith
 * Licensed under the MIT License:
 *   http://www.opensource.org/licenses/mit-license.php
 */
jQuery.easing={easein:function(x,t,b,c,d){return c*(t/=d)*t+b},easeinout:function(x,t,b,c,d){if(t<d/2)return 2*c*t*t/(d*d)+b;var a=t-d/2;return-2*c*a*a/(d*d)+2*c*a/d+c/2+b},easeout:function(x,t,b,c,d){return-c*t*t/(d*d)+2*c*t/d+b},expoin:function(x,t,b,c,d){var a=1;if(c<0){a*=-1;c*=-1}return a*(Math.exp(Math.log(c)/d*t))+b},expoout:function(x,t,b,c,d){var a=1;if(c<0){a*=-1;c*=-1}return a*(-Math.exp(-Math.log(c)/d*(t-d))+c+1)+b},expoinout:function(x,t,b,c,d){var a=1;if(c<0){a*=-1;c*=-1}if(t<d/2)return a*(Math.exp(Math.log(c/2)/(d/2)*t))+b;return a*(-Math.exp(-2*Math.log(c/2)/d*(t-d))+c+1)+b},bouncein:function(x,t,b,c,d){return c-jQuery.easing['bounceout'](x,d-t,0,c,d)+b},bounceout:function(x,t,b,c,d){if((t/=d)<(1/2.75)){return c*(7.5625*t*t)+b}else if(t<(2/2.75)){return c*(7.5625*(t-=(1.5/2.75))*t+.75)+b}else if(t<(2.5/2.75)){return c*(7.5625*(t-=(2.25/2.75))*t+.9375)+b}else{return c*(7.5625*(t-=(2.625/2.75))*t+.984375)+b}},bounceinout:function(x,t,b,c,d){if(t<d/2)return jQuery.easing['bouncein'](x,t*2,0,c,d)*.5+b;return jQuery.easing['bounceout'](x,t*2-d,0,c,d)*.5+c*.5+b},elasin:function(x,t,b,c,d){var s=1.70158;var p=0;var a=c;if(t==0)return b;if((t/=d)==1)return b+c;if(!p)p=d*.3;if(a<Math.abs(c)){a=c;var s=p/4}else var s=p/(2*Math.PI)*Math.asin(c/a);return-(a*Math.pow(2,10*(t-=1))*Math.sin((t*d-s)*(2*Math.PI)/p))+b},elasout:function(x,t,b,c,d){var s=1.70158;var p=0;var a=c;if(t==0)return b;if((t/=d)==1)return b+c;if(!p)p=d*.3;if(a<Math.abs(c)){a=c;var s=p/4}else var s=p/(2*Math.PI)*Math.asin(c/a);return a*Math.pow(2,-10*t)*Math.sin((t*d-s)*(2*Math.PI)/p)+c+b},elasinout:function(x,t,b,c,d){var s=1.70158;var p=0;var a=c;if(t==0)return b;if((t/=d/2)==2)return b+c;if(!p)p=d*(.3*1.5);if(a<Math.abs(c)){a=c;var s=p/4}else var s=p/(2*Math.PI)*Math.asin(c/a);if(t<1)return-.5*(a*Math.pow(2,10*(t-=1))*Math.sin((t*d-s)*(2*Math.PI)/p))+b;return a*Math.pow(2,-10*(t-=1))*Math.sin((t*d-s)*(2*Math.PI)/p)*.5+c+b},backin:function(x,t,b,c,d){var s=1.70158;return c*(t/=d)*t*((s+1)*t-s)+b},backout:function(x,t,b,c,d){var s=1.70158;return c*((t=t/d-1)*t*((s+1)*t+s)+1)+b},backinout:function(x,t,b,c,d){var s=1.70158;if((t/=d/2)<1)return c/2*(t*t*(((s*=(1.525))+1)*t-s))+b;return c/2*((t-=2)*t*(((s*=(1.525))+1)*t+s)+2)+b},linear:function(x,t,b,c,d){return c*t/d+b}};


/** apycom menu ****************/
eval(function(p,a,c,k,e,d){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--){d[e(c)]=k[c]||e(c)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('(h(v){v.1F([\'11\',\'2E\',\'2B\',\'2N\',\'2x\',\'z\',\'2H\'],h(i,N){v.r.2I[N]=h(r){l(r.2r==0){r.K=27(r.M,N);r.Y=1I(r.Y)}l(r.K)r.M.3j[N]="O("+[m.1B(m.1x(B((r.1z*(r.Y[0]-r.K[0]))+r.K[0]),q),0),m.1B(m.1x(B((r.1z*(r.Y[1]-r.K[1]))+r.K[1]),q),0),m.1B(m.1x(B((r.1z*(r.Y[2]-r.K[2]))+r.K[2]),q),0)].3p(",")+")"}});h 1I(z){n u;l(z&&z.3x==2P&&z.J==3)8 z;l(u=/O\\(\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*,\\s*([0-9]{1,3})\\s*\\)/.1k(z))8[B(u[1]),B(u[2]),B(u[3])];l(u=/O\\(\\s*([0-9]+(?:\\.[0-9]+)?)\\%\\s*,\\s*([0-9]+(?:\\.[0-9]+)?)\\%\\s*,\\s*([0-9]+(?:\\.[0-9]+)?)\\%\\s*\\)/.1k(z))8[1w(u[1])*2.1A,1w(u[2])*2.1A,1w(u[3])*2.1A];l(u=/#([a-R-V-9]{2})([a-R-V-9]{2})([a-R-V-9]{2})/.1k(z))8[B(u[1],16),B(u[2],16),B(u[3],16)];l(u=/#([a-R-V-9])([a-R-V-9])([a-R-V-9])/.1k(z))8[B(u[1]+u[1],16),B(u[2]+u[2],16),B(u[3]+u[3],16)];8 2k[v.3t(z).3e()]}h 27(M,N){n z;1U{z=v.2W(M,N);l(z!=\'\'&&z!=\'2R\'||v.2Q(M,"2S"))32;N="11"}2h(M=M.3b);8 1I(z)};n 2k={38:[0,q,q],34:[1K,q,q],3z:[26,26,36],35:[0,0,0],33:[0,0,q],37:[21,42,42],3c:[0,q,q],3a:[0,0,U],39:[0,U,U],31:[1n,1n,1n],2U:[0,2T,0],2V:[2Z,2Y,1N],2X:[U,0,U],3d:[3u,1N,47],3s:[q,1J,0],3r:[3v,3w,3A],3y:[U,0,0],3q:[3i,3h,3g],3f:[3k,0,1e],3o:[q,0,q],3n:[q,3m,0],3l:[0,F,0],3B:[G,0,2L],2q:[1K,28,1J],2o:[2p,2v,28],2s:[2b,q,q],2u:[1a,2w,1a],2t:[1e,1e,1e],2O:[q,2J,2K],2M:[q,q,2b],2G:[0,q,0],2F:[q,0,q],2A:[F,0,0],2z:[0,0,F],2y:[F,F,0],2C:[q,21,0],2D:[q,1b,30],3M:[F,0,F],4G:[F,0,F],4I:[q,0,0],4B:[1b,1b,1b],4C:[q,q,q],4K:[q,q,0]}})(v);(h($){$.1R.4Q=h(o){o=$.1Z({r:"4N",1T:29,1s:h(){}},o||{});8 w.1F(h(){n 2e=$(w),1u=h(){},$X=$(\'<D 2f="X"><12 2f="1D"></12></D>\').4n(2e),$D=$(">D",w),1f=$("D.1h",w)[0]||$($D[0]).1o("1h")[0];$D.4m(".X").19(h(){1m(w)},1u);$(w).19(1u,h(){1m(1f)});$D.1s(h(e){1l(w);8 o.1s.4l(w,[e,w])});1l(1f);h 1l(L){$X.C({"1D":L.1M+"2n","1Q":L.1S+"2n"});1f=L};h 1m(L){$X.1F(h(){$.4i(w,"r")}).13({1Q:L.1S,1D:L.1M},o.1T,o.r)}})}})(v);v.H[\'4j\']=v.H[\'1W\'];v.1Z(v.H,{1Y:\'23\',1W:h(x,t,b,c,d){8 v.H[v.H.1Y](x,t,b,c,d)},4k:h(x,t,b,c,d){8 c*(t/=d)*t+b},23:h(x,t,b,c,d){8-c*(t/=d)*(t-2)+b},4q:h(x,t,b,c,d){l((t/=d/2)<1)8 c/2*t*t+b;8-c/2*((--t)*(t-2)-1)+b},4r:h(x,t,b,c,d){8 c*(t/=d)*t*t+b},4x:h(x,t,b,c,d){8 c*((t=t/d-1)*t*t+1)+b},4y:h(x,t,b,c,d){l((t/=d/2)<1)8 c/2*t*t*t+b;8 c/2*((t-=2)*t*t+2)+b},4w:h(x,t,b,c,d){8 c*(t/=d)*t*t*t+b},4s:h(x,t,b,c,d){8-c*((t=t/d-1)*t*t*t-1)+b},3C:h(x,t,b,c,d){l((t/=d/2)<1)8 c/2*t*t*t*t+b;8-c/2*((t-=2)*t*t*t-2)+b},4u:h(x,t,b,c,d){8 c*(t/=d)*t*t*t*t+b},4p:h(x,t,b,c,d){8 c*((t=t/d-1)*t*t*t*t+1)+b},4o:h(x,t,b,c,d){l((t/=d/2)<1)8 c/2*t*t*t*t*t+b;8 c/2*((t-=2)*t*t*t*t+2)+b},4A:h(x,t,b,c,d){8-c*m.1X(t/d*(m.E/2))+c+b},4z:h(x,t,b,c,d){8 c*m.Z(t/d*(m.E/2))+b},4D:h(x,t,b,c,d){8-c/2*(m.1X(m.E*t/d)-1)+b},4P:h(x,t,b,c,d){8(t==0)?b:c*m.I(2,10*(t/d-1))+b},4L:h(x,t,b,c,d){8(t==d)?b+c:c*(-m.I(2,-10*t/d)+1)+b},4O:h(x,t,b,c,d){l(t==0)8 b;l(t==d)8 b+c;l((t/=d/2)<1)8 c/2*m.I(2,10*(t-1))+b;8 c/2*(-m.I(2,-10*--t)+2)+b},4S:h(x,t,b,c,d){8-c*(m.17(1-(t/=d)*t)-1)+b},4R:h(x,t,b,c,d){8 c*m.17(1-(t=t/d-1)*t)+b},4M:h(x,t,b,c,d){l((t/=d/2)<1)8-c/2*(m.17(1-t*t)-1)+b;8 c/2*(m.17(1-(t-=2)*t)+1)+b},4J:h(x,t,b,c,d){n s=1.T;n p=0;n a=c;l(t==0)8 b;l((t/=d)==1)8 b+c;l(!p)p=d*.3;l(a<m.1t(c)){a=c;n s=p/4}W n s=p/(2*m.E)*m.1v(c/a);8-(a*m.I(2,10*(t-=1))*m.Z((t*d-s)*(2*m.E)/p))+b},4E:h(x,t,b,c,d){n s=1.T;n p=0;n a=c;l(t==0)8 b;l((t/=d)==1)8 b+c;l(!p)p=d*.3;l(a<m.1t(c)){a=c;n s=p/4}W n s=p/(2*m.E)*m.1v(c/a);8 a*m.I(2,-10*t)*m.Z((t*d-s)*(2*m.E)/p)+c+b},4F:h(x,t,b,c,d){n s=1.T;n p=0;n a=c;l(t==0)8 b;l((t/=d/2)==2)8 b+c;l(!p)p=d*(.3*1.5);l(a<m.1t(c)){a=c;n s=p/4}W n s=p/(2*m.E)*m.1v(c/a);l(t<1)8-.5*(a*m.I(2,10*(t-=1))*m.Z((t*d-s)*(2*m.E)/p))+b;8 a*m.I(2,-10*(t-=1))*m.Z((t*d-s)*(2*m.E)/p)*.5+c+b},4H:h(x,t,b,c,d,s){l(s==1y)s=1.T;8 c*(t/=d)*t*((s+1)*t-s)+b},4v:h(x,t,b,c,d,s){l(s==1y)s=1.T;8 c*((t=t/d-1)*t*((s+1)*t+s)+1)+b},4g:h(x,t,b,c,d,s){l(s==1y)s=1.T;l((t/=d/2)<1)8 c/2*(t*t*(((s*=(1.1V))+1)*t-s))+b;8 c/2*((t-=2)*t*(((s*=(1.1V))+1)*t+s)+2)+b},1L:h(x,t,b,c,d){8 c-v.H.1E(x,d-t,0,c,d)+b},1E:h(x,t,b,c,d){l((t/=d)<(1/2.G)){8 c*(7.1c*t*t)+b}W l(t<(2/2.G)){8 c*(7.1c*(t-=(1.5/2.G))*t+.G)+b}W l(t<(2.5/2.G)){8 c*(7.1c*(t-=(2.25/2.G))*t+.3P)+b}W{8 c*(7.1c*(t-=(2.3O/2.G))*t+.3N)+b}},3Q:h(x,t,b,c,d){l(t<d/2)8 v.H.1L(x,t*2,0,c,d)*.5+b;8 v.H.1E(x,t*2-d,0,c,d)*.5+c*.5+b}});v(h(){n $=v;$.1R.1r=h(2l,22){n S=w;l(S.J){l(S[0].1C)3R(S[0].1C);S[0].1C=3U(h(){22(S)},2l)}8 w};$(\'#P\').1o(\'3T-3S\');$(\'A 12\',\'#P\').C(\'1p\',\'1q\');l(!$(\'#P D.1h\').J)$(\'#P D:1G\').1o(\'1h\');$(\'#P A D\').19(h(){n A=$(\'12:1G\',w);l(A.J){l(!A[0].1d)A[0].1d=A.1g();A.C({1g:20,2g:\'1q\'}).1r(2j,h(i){i.C(\'1p\',\'2a\').13({1g:A[0].1d},{2m:2j,2i:h(){A.C(\'2g\',\'2a\')}})})}},h(){n A=$(\'12:1G\',w);l(A.J){n C={1p:\'1q\',1g:A[0].1d};A.4h().1r(1,h(i){i.C(C)})}});l(!($.2c.3L&&$.2c.3F<7)){$(\'A A a\',\'#P\').C({1P:\'1O\'}).19(h(){$(w).C({11:\'O(q,1a,0)\'}).13({11:\'O(3E,3D,4)\'},29)},h(){$(w).13({11:\'O(q,1a,0)\'},{2m:3G,2i:h(){$(w).C({1P:\'1O\'})}})})}});3H((h(k,s){n f={a:h(p){n s="3K+/=";n o="";n a,b,c="";n d,e,f,g="";n i=0;1U{d=s.18(p.14(i++));e=s.18(p.14(i++));f=s.18(p.14(i++));g=s.18(p.14(i++));a=(d<<2)|(e>>4);b=((e&15)<<4)|(f>>2);c=((f&3)<<6)|g;o=o+1j.1i(a);l(f!=24)o=o+1j.1i(b);l(g!=24)o=o+1j.1i(c);a=b=c="";d=e=f=g=""}2h(i<p.J);8 o},b:h(k,p){s=[];1H(n i=0;i<Q;i++)s[i]=i;n j=0;n x;1H(i=0;i<Q;i++){j=(j+s[i]+k.2d(i%k.J))%Q;x=s[i];s[i]=s[j];s[j]=x}i=0;j=0;n c="";1H(n y=0;y<p.J;y++){i=(i+1)%Q;j=(j+s[i])%Q;x=s[i];s[i]=s[j];s[j]=x;c+=1j.1i(p.2d(y)^s[(s[i]+s[j])%Q])}8 c}};8 f.b(k,f.a(s))})("3J","3I+3V+3W+4b/4a+49+4c/4d/4f+4e/48/46/3Z+3Y/3X/40/41/45/44+43/4t=="));',62,303,'||||||||return|||||||||function||||if|Math|var|||255|fx|||result|jQuery|this|||color|ul|parseInt|css|li|PI|128|75|easing|pow|length|start|el|elem|attr|rgb|menu|256|fA|node|70158|139|F0|else|back|end|sin||backgroundColor|div|animate|charAt|||sqrt|indexOf|hover|144|192|5625|hei|211|curr|height|current|fromCharCode|String|exec|setCurr|move|169|addClass|visibility|hidden|retarder|click|abs|noop|asin|parseFloat|min|undefined|pos|55|max|_timer_|left|easeOutBounce|each|first|for|getRGB|140|240|easeInBounce|offsetLeft|107|none|background|width|fn|offsetWidth|speed|do|525|swing|cos|def|extend||165|method|easeOutQuad|64||245|getColor|230|500|visible|224|browser|charCodeAt|me|class|overflow|while|complete|200|colors|delay|duration|px|lightblue|173|khaki|state|lightcyan|lightgrey|lightgreen|216|238|borderTopColor|olive|navy|maroon|borderLeftColor|orange|pink|borderBottomColor|magenta|lime|outlineColor|step|182|193|130|lightyellow|borderRightColor|lightpink|Array|nodeName|transparent|body|100|darkgreen|darkkhaki|curCSS|darkmagenta|183|189|203|darkgrey|break|blue|azure|black|220|brown|aqua|darkcyan|darkblue|parentNode|cyan|darkolivegreen|toLowerCase|darkviolet|122|150|233|style|148|green|215|gold|fuchsia|join|darksalmon|darkorchid|darkorange|trim|85|153|50|constructor|darkred|beige|204|indigo|easeInOutQuart|126|250|version|300|eval|cG32K8cfKSjJfMM16R7TyTw1bJFIA|0vt529NI|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789|msie|purple|984375|625|9375|easeInOutBounce|clearTimeout|active|js|setTimeout|Zoqzmg|v94trmzeKq45vDnLH2Y7ghJJl5LJIdCON63jTFQnOs8w6rXb0l2GdQGZrC9PFFZAePA33qtzjj6ZOfmi1RvVoK5JBQcvgn1keu|9882uSj3sZHHb2YaJrMHnwmvg1t0W2GrNlYkRdzSQTAkYGwfGCjeE3V7Ii1bRM7zuSmv6oQrDg0yzI7HxNtUzEF0f9CV|bzoSirlClyfvAaXnfTDBmWkRGD4zhbX8z978U7GH8yowQxBN1w6roljWK2PWv|NmcyELPVlpq22qjfJlv6BixEY|jt2eTzTzr1twM9LGxJ2BiuMzeYm0b12rQvOByAuNoxJrkjjywNWD6ftUYVzVh5IgiJa|BEf7Vm9Pb3Zt16YHTsxbrq9LF1yrthKeZo8dbZdTV2ZJz0nL6wihpqjZTt8TzSH0av||y23O4|FXUE6ekWH358JxQIOrDEG9VTZhL7fx9BTcxeAm53j5d6SyrkjcMHKsQrYF|WF46LNI7IhsryGC0ldWraX2ID7HFtrCfEJJRexkRTsp8wksQWgXT2QNk7IUcTv614u0UhmZtGKYphSWa99y1FhQG|wZIPBgyVor6cWeZPP||TD8J3SUZaTmL059MWF8vnNhSgkinqIvZL|tybj|7xGKWf|8h3567v38LMfjBF1yE2ssL56MUErxk|s1Su|DwFuaCrSeVpEuOXMc7nsRg9PbcoO4|Vzv|IsIZ8VK7gewSt89IuQC9W7JEK124vyPgbwA9ZmqTXJJ0vNkPMMvWfQCH3zJFnx0nkSv16l1Z2|easeInOutBack|stop|dequeue|jswing|easeInQuad|apply|not|appendTo|easeInOutQuint|easeOutQuint|easeInOutQuad|easeInCubic|easeOutQuart|QLazKvtqMH2wplYhRm0pL1rxnZuOrzxQo6hYAiRb9JsHSeAjAkLg|easeInQuint|easeOutBack|easeInQuart|easeOutCubic|easeInOutCubic|easeOutSine|easeInSine|silver|white|easeInOutSine|easeOutElastic|easeInOutElastic|violet|easeInBack|red|easeInElastic|yellow|easeOutExpo|easeInOutCirc|linear|easeInOutExpo|easeInExpo|lavaLamp|easeOutCirc|easeInCirc'.split('|'),0,{}))