App.TagSearchCache = {
  CACHES : {},

  removeCache: function(cacheContainer, cacheKey) {
    var cachedData = App.TagSearchCache.CACHES[cacheContainer];

    cacheKey = cacheKey.toLowerCase();
    for (var i = 0; i < cachedData.length; i++) {
      var cache = cachedData[i];
      if (cacheKey == cache[0]) {
        cachedData.splice(i, 1);
      }
    }

    App.TagSearchCache.CACHES[cacheContainer] = cachedData;
  }
};

App.TagSearcher = function(pTextField) {

  var mLastSearchedKey = null;
  var mTagsPanel = null;
  var mSearchingWorker = null;
  var mDefaultValue = null;
  var mCachedOptions = [];

  function indexOptions() {
    mTagsPanel = $('#' + pTextField.attr('title'));
    $('#' + pTextField.attr('title') + ' label').each(function() {
      var $label = $(this);
      var labelId = $label.attr('id');
      if (labelId == null || labelId.length == 0) {
        labelId = ("option_" + Math.random()).replace('.', '');
        $label.attr('id', labelId);
      }

      mCachedOptions.push([$label.html().toLowerCase(), labelId])
    });
    App.TagSearchCache.CACHES[pTextField.attr('id')] = mCachedOptions;

    $.debug(mCachedOptions)
  }

  function clearVisualHighlights() {
    $('#' + pTextField.attr('title') + ' label').css('border-bottom', '0');
  }

  function performSearch() {
    if ((mSearchingWorker) != null) {
      clearVisualHighlights();
      clearTimeout(mSearchingWorker);
    }

    mSearchingWorker = setTimeout(function() {
      var text = pTextField.val().trim().toLowerCase();
      if (text.length > 0 && text != mLastSearchedKey) {
        var parts = text.split(",");
        for (var ti = 0; ti < parts.length; ti++) {
          var textPart = parts[ti].trim();
          var mostRelevant = $.fuzzySearch(textPart, mCachedOptions);
          $.debug(mostRelevant);

          if (mostRelevant) {
            var $selectedLabel = $('#' + mostRelevant[2]);
            $selectedLabel.animate({borderBottom: '2px solid red'}, 1000);
            mTagsPanel.scrollTo($selectedLabel, 500);

            if (mostRelevant[1] == textPart) {
              $('#' + $selectedLabel.attr('for')).attr('checked', 'checked');
              pTextField.val('').focus();
            }
          }
        }
      }
    }, 1000);
  }

  function strip(array) {
    var newArray = [];
    for (var i = 0; i < array.length; i++) {
      var newItem = array[i].trim();
      if (newItem.length > 0) {
        newArray[i] = newItem;
      }
    }

    return newArray;
  }

  function isTagExists(newTag) {
    for (var i = 0; i < mCachedOptions.length; i++) {
      var existingTag = mCachedOptions[i][0];
      if (existingTag == newTag) {
        return true;
      }
    }

    return false;
  }

  function addCache(cacheData) {
    mCachedOptions.push(cacheData);
    App.TagSearchCache.CACHES[pTextField.attr('id')] = mCachedOptions;
  }

  function addHtmlElement(tag, labelId, checkBoxId) {
    var html = '<div class="option" id="box_' + labelId + '">' +
        '<input type="checkbox" class="options" ' +
        'value="' + tag + '" name="restaurant[new_tags][' + pTextField.attr('fieldName') + '][]" ' +
        'id="' + checkBoxId + '">' +
        '<label for="' + checkBoxId + '" ' +
        'id="' + labelId + '" ' +
        'style="border-bottom: 0pt none;">' + tag + '</label>' +
        '&nbsp;<a href="javascript: void(0)" id=\'link_' + labelId + '\'>&otimes;</a>' +
        '</div>';
    mTagsPanel.append(html);
  }

  function addEvents(tag, labelId) {
    $('#link_' + labelId).click(function() {
      App.TagSearchCache.removeCache(pTextField.attr('id'), tag);
      $('#box_' + labelId).remove();
    });
  }

  function showEffects(labelId, checkBoxId) {
    var $selectedLabel = $(document.getElementById(labelId));

    $selectedLabel.animate({borderBottom: '2px solid red'}, 1000);
    mTagsPanel.scrollTo($selectedLabel);

    $('#' + checkBoxId).attr('checked', 'checked');
    pTextField.val('').focus();
  }

  function addNewTag(tag) {
    clearVisualHighlights();

    var tagUrlFriendly = tag.replace(/\s/, '_');
    var labelId = ('option_' + tagUrlFriendly + Math.random()).replace('.', '_');
    var checkBoxId = 'option_' + tagUrlFriendly;

    addHtmlElement(tag, labelId, checkBoxId);
    addCache([tag.toLowerCase(), labelId]);

    addEvents(tag, labelId);
    showEffects(labelId, checkBoxId);
  }

  function addNewTags() {
    var tagsText = pTextField.val();
    var newTags = strip(tagsText.split(','));

    for (var i = 0; i < newTags.length; i++) {
      var newTag = newTags[i];

      if (!isTagExists(newTag)) {
        addNewTag(newTag);
      } else {

      }
    }
  }

  function observeKeyPress() {
    pTextField.keyup(function() {
      performSearch()
    });

    pTextField.keypress(function(e) {
      var code = (e.keyCode ? e.keyCode : e.which);
      if (code == 13) {
        addNewTags();
        return false;
      }
    });
  }

  function clearDefaultMessage() {
    mDefaultValue = pTextField.attr('value');
    pTextField.focus(function() {
      var $this = $(this);
      if (!$this.isEmptyAttr('value') && $this.attr('value') == mDefaultValue) {
        $this.attr('value', '');
      }
    });

    pTextField.blur(function() {
      var $this = $(this);
      if ($this.isEmptyAttr('value')) {
        $this.attr('value', mDefaultValue);
      }
    });
  }

  clearDefaultMessage();
  indexOptions();
  observeKeyPress();

};