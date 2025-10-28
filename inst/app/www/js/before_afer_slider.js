(function($) {

  function drags($dragElement, $resizeElement, $container, $dividerLine) {
    $dragElement.on('mousedown.ba-events touchstart.ba-events', function(e) {
      $dragElement.addClass('ba-draggable');
      $resizeElement.addClass('ba-resizable');

      var startX = e.pageX || e.originalEvent.touches[0].pageX;
      var dragWidth = $dragElement.outerWidth(),
          posX = $dragElement.offset().left + dragWidth / 2 - startX,
          containerOffset = $container.offset().left,
          containerWidth = $container.outerWidth();

      var minLeft = containerOffset + 0;
      var maxLeft = containerOffset + containerWidth;

      $(document).on('mousemove.ba-events touchmove.ba-events', function(e) {
        var moveX = e.pageX || e.originalEvent.touches[0].pageX;
        var leftValue = moveX + posX;

        if (leftValue < minLeft) leftValue = minLeft;
        if (leftValue > maxLeft) leftValue = maxLeft;

        var percent = ((leftValue - containerOffset) * 100 / containerWidth);

        // Clamp between 1% and 99%
        if (percent < 1) percent = 1;
        if (percent > 99) percent = 99;

        var widthValue = percent + '%';

        $dragElement.css('left', widthValue);
        $resizeElement.css('width', widthValue);
        $dividerLine.css('left', widthValue);

        $dragElement.attr('aria-valuenow', percent.toFixed(0));
      });

      $(document).on('mouseup.ba-events touchend.ba-events touchcancel.ba-events', function() {
        $dragElement.removeClass('ba-draggable');
        $resizeElement.removeClass('ba-resizable');
        $(document).off('.ba-events');
      });

      e.preventDefault();
    });
  }

  $.fn.beforeAfter = function(options) {
    const settings = $.extend({
      introDelay: 0,
      introDuration: 0
    }, options);

    return this.each(function() {
      const $container = $(this);
      const $children = $container.children();

      if ($children.length < 2) {
        console.warn('beforeAfter: container needs two child elements (before & after).');
        return;
      }

      const $before = $children.eq(0);
      const $after = $children.eq(1);

      let $resize;
      if (!$after.hasClass('resize')) {
        $after.wrap('<div class="resize"></div>');
        $resize = $after.parent();
      } else {
        $resize = $after;
      }

      // Remove old elements
      $container.find('.handle-circle, .beforeafter-divider-line').remove();

      // Create handle first
      const $handle = $(`
        <div class="handle-circle" tabindex="0" role="slider"
             aria-label="Image comparison slider"
             aria-valuemin="0" aria-valuemax="100" aria-valuenow="50">
          <div class="handle-grip">
            <span class="arrow left"></span>
            <span class="arrow right"></span>
          </div>
        </div>
      `);
      $container.append($handle);

      // Create full-height divider line (must come *after* handle for CSS sibling selector)
      const $dividerLine = $('<div class="beforeafter-divider-line"></div>');
      $container.append($dividerLine);

      $container.css({ position: 'relative', overflow: 'hidden' });
      $before.css({ display: 'block', width: '100%' });
      $resize.css({
        position: 'absolute',
        top: 0,
        left: 0,
        width: '50%',
        height: '100%',
        overflow: 'hidden'
      });

      $handle.css('left', '50%');
      $dividerLine.css('left', '50%');

      drags($handle, $resize, $container, $dividerLine);

      // Keyboard support
      function getCurrentPercent() {
        const left = parseFloat($handle.css('left')) || 0;
        const cw = $container.width();
        return (left / cw) * 100;
      }

      function setPosition(percent) {
        // Clamp between 1% and 99%
        percent = Math.max(1, Math.min(99, percent));

        const widthValue = percent + '%';
        $handle.css('left', widthValue);
        $resize.css('width', widthValue);
        $dividerLine.css('left', widthValue);
        $handle.attr('aria-valuenow', percent.toFixed(0));
      }

      $handle.on('keydown', function(e) {
        const step = 2;
        let percent = getCurrentPercent();
        if (e.key === 'ArrowLeft') {
          e.preventDefault();
          setPosition(percent - step);
        } else if (e.key === 'ArrowRight') {
          e.preventDefault();
          setPosition(percent + step);
        }
      });

      $handle.on('focus', () => $handle.addClass('ba-draggable'));
      $handle.on('blur', () => $handle.removeClass('ba-draggable'));

      // Intro animation (optional)
      if (settings.introDelay > 0 && settings.introDuration > 0) {
        $resize.css('width', '100%');
        $handle.css('left', '100%');
        $dividerLine.css('left', '100%');
        setTimeout(() => {
          $resize.animate({ width: '50%' }, settings.introDuration);
          $handle.animate({ left: '50%' }, settings.introDuration);
          $dividerLine.animate({ left: '50%' }, settings.introDuration);
        }, settings.introDelay);
      }

      // Responsive resize
      $(window).on('resize', function() {
        const width = $container.width() + 'px';
        $container.find('.resize img').css('width', width);
      });
    });
  };
})(jQuery);
