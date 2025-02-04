/* x_event.js compiled from X 4.0 with XC 0.27b. Distributed by GNU LGPL. For copyrights, license, documentation and more visit Cross-Browser.com */
function xAddEventListener(e, eT, eL, cap) {
    if (!(e = xGetElementById(e))) return;
    eT = eT.toLowerCase();
    if ((!xIE4Up && !xOp7Up) && e == window) {
        if (eT == 'resize') {
            window.xPCW = xClientWidth();
            window.xPCH = xClientHeight();
            window.xREL = eL;
            xResizeEvent();
            return;
        }
        if (eT == 'scroll') {
            window.xPSL = xScrollLeft();
            window.xPST = xScrollTop();
            window.xSEL = eL;
            xScrollEvent();
            return;
        }
    }
    var eh = 'e.on' + eT + '=eL';
    if (e.addEventListener) e.addEventListener(eT, eL, cap); else if (e.attachEvent) e.attachEvent('on' + eT, eL); else eval(eh);
}

function xResizeEvent() {
    if (window.xREL) setTimeout('xResizeEvent()', 250);
    var cw = xClientWidth(), ch = xClientHeight();
    if (window.xPCW != cw || window.xPCH != ch) {
        window.xPCW = cw;
        window.xPCH = ch;
        if (window.xREL) window.xREL();
    }
}

function xScrollEvent() {
    if (window.xSEL) setTimeout('xScrollEvent()', 250);
    var sl = xScrollLeft(), st = xScrollTop();
    if (window.xPSL != sl || window.xPST != st) {
        window.xPSL = sl;
        window.xPST = st;
        if (window.xSEL) window.xSEL();
    }
}

function xEvent(evt) {
    var e = evt || window.event;
    if (!e) return;
    if (e.type) this.type = e.type;
    if (e.target) this.target = e.target; else if (e.srcElement) this.target = e.srcElement;
    if (e.relatedTarget) this.relatedTarget = e.relatedTarget; else if (e.type == 'mouseover' && e.fromElement) this.relatedTarget = e.fromElement; else if (e.type == 'mouseout') this.relatedTarget = e.toElement;
    if (xOp6Dn) {
        this.pageX = e.clientX;
        this.pageY = e.clientY;
    } else if (xDef(e.pageX, e.pageY)) {
        this.pageX = e.pageX;
        this.pageY = e.pageY;
    } else if (xDef(e.clientX, e.clientY)) {
        this.pageX = e.clientX + xScrollLeft();
        this.pageY = e.clientY + xScrollTop();
    }
    if (xDef(e.offsetX, e.offsetY)) {
        this.offsetX = e.offsetX;
        this.offsetY = e.offsetY;
    } else if (xDef(e.layerX, e.layerY)) {
        this.offsetX = e.layerX;
        this.offsetY = e.layerY;
    } else {
        this.offsetX = this.pageX - xPageX(this.target);
        this.offsetY = this.pageY - xPageY(this.target);
    }
    if (e.keyCode) {
        this.keyCode = e.keyCode;
    } else if (xDef(e.which) && e.type.indexOf('key') != -1) {
        this.keyCode = e.which;
    }
    this.shiftKey = e.shiftKey;
    this.ctrlKey = e.ctrlKey;
    this.altKey = e.altKey;
}

function xPreventDefault(e) {
    if (e && e.preventDefault) e.preventDefault(); else if (window.event) window.event.returnValue = false;
}

function xRemoveEventListener(e, eT, eL, cap) {
    if (!(e = xGetElementById(e))) return;
    eT = eT.toLowerCase();
    if ((!xIE4Up && !xOp7Up) && e == window) {
        if (eT == 'resize') {
            window.xREL = null;
            return;
        }
        if (eT == 'scroll') {
            window.xSEL = null;
            return;
        }
    }
    var eh = 'e.on' + eT + '=null';
    if (e.removeEventListener) e.removeEventListener(eT, eL, cap); else if (e.detachEvent) e.detachEvent('on' + eT, eL); else eval(eh);
}

function xStopPropagation(evt) {
    if (evt && evt.stopPropagation) evt.stopPropagation(); else if (window.event) window.event.cancelBubble = true;
}
