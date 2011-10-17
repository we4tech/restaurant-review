/**
 * Pull down menu implementation for http://welltreat.us
 * This is been designed on jQuery framework.
 */

if (typeof(WellTreatUs) == 'undefined') {
  var WellTreatUs = {};
}

/**
 * Make the given menu link as a pull down menu for the given menu items.
 * @param menuLink a jQuery object instance
 * @param menuItems a jQuery object instance
 */
WellTreatUs.PullDownMenu = function(menuLink, menuItems, options) {
  var mTimer = null;
  var MENU_PARENT_CLASS = 'wtsPullDownHover';
  var MENU_CLASS = 'wtsPullDownMenu';
  var SUB_MENU_CLASS = 'wtsPullDownSubMenu';

  var mAfterLoadedCallback = null;

  this.startTimer = function() {
    this.stopTimer();
    mTimer = setTimeout(this.hideSubMenu, 500);
  };

  this.stopTimer = function() {
    if (mTimer) {
      clearTimeout(mTimer);
    }
  };

  this.hideSubMenu = function() {
    menuItems.slideUp({easing: 'jswing'});
    menuItems.parent().removeClass(MENU_PARENT_CLASS);
    menuLink.parent().removeClass(MENU_PARENT_CLASS);
  };

  this.setupEvents = function() {
    var $this = this;

    if (typeof(options) != 'undefined') {
      if (options.after) {
        mAfterLoadedCallback = options.after;
      }
    }

    // Set CSS classes
    menuLink.removeClass(MENU_CLASS).addClass(MENU_CLASS);
    menuItems.removeClass(SUB_MENU_CLASS).addClass(SUB_MENU_CLASS);

    menuLink.click(function(e) {
      if (menuItems.css('display') == 'none' || menuItems.css('display') == '') {
        $(window).trigger('click', {target: {}});

        if (!menuLink.parent().hasClass(MENU_PARENT_CLASS)) {
          menuLink.parent().addClass(MENU_PARENT_CLASS);
        }
        menuItems.slideDown({easing: 'jswing'});
        if (mAfterLoadedCallback) {
          mAfterLoadedCallback();
        }
      }
    });

    $(window).bind('click', function(e) {
      if (e.target !== menuLink[0] && menuLink.parent().hasClass(MENU_PARENT_CLASS)) {
        $this.startTimer();
      }
    });
  };

  // Self execution
  this.setupEvents();
};


/**
 * Integrate as a jquery extension and
 * expose jQueryInstance.wtsPullDown(jQueryInstanceOfMenuItems);
 */
(function($) {

  /**
   * Build Pull down menu for the specified menu items jquery object.
   * This is must be a list of items (which will be shown under the pull down menu).
   * user can control the appearance by altering the css.
   *
   * Interestingly we are not adding any css class for appearance
   * rather adding css class for showing the current status.
   *
   * @param menuItems a jquery object
   */
  $.fn.wtsPullDown = function(menuItems, options) {
    new WellTreatUs.PullDownMenu(this, menuItems, options);
  };
})(jQuery);
