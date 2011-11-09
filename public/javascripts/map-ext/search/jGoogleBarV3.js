/**************************************************
*
* jGoogleBarV3.js
* A Google (Search) Bar for GMaps API V3 applications
* 
* Copyright (c) 2010, Jeremy R. Geerdes
* You are free to copy and use this sample under the terms of the Apache License, Version 2.0.
* For a copy of the license, view http://www.apache.org/licenses/LICENSE-2.0
*
* This script is offered AS-IS, with absolutely no warranty of any kind.
* 
**************************************************/


(function(){
 var   gsearch_css='default.css', // You need to edit this so it it points to your version of the default.css
  m=google.maps, // fewer keystrokes is good
  gmlocalsearch_css='http://www.google.com/uds/solutions/localsearch/gmlocalsearch.css',
  defaultOptions={ // default options for the control; should be pretty self-explanatory
   'resultSetSize' : 8,
   'clearResultsString' : 'X',
   'minimizeResultsString' : '_',
   'maximizeResultsString' : '^',
   'icons' : [],
   'shadow' : new m['MarkerImage']('http://www.google.com/mapfiles/gadget/shadow50Small80.png',null,null,new m.Point(8,28)),
   'showResultsList' : true,
   'showResultsMarkers' : true,
   'searchFormOptions' : {}
  };
 
 for(var i=0;i<8;i++){ // initialize our default markers
  defaultOptions['icons'].push(google['loader']['ServiceBase'] + "/solutions/localsearch/img/pin_metalred_" + String.fromCharCode(65+i) + ".png");
 }

 if(!window['noGBarCSS']){ // load the CSS if we want it
  var style=createEl('link',null,null,{ // let's add the gmlocalsearch.css stylesheet we're going to need
           'href' : gmlocalsearch_css,
           'rel' : 'stylesheet',
           'type' : 'text/css'
          }),
   otherStyle=createEl('link',null,null,{ // let's add the default.css we're going to need
                        'href' : gsearch_css,
                        'rel' : 'stylesheet',
                        'type' : 'text/css'
                       }),
   headEl=document.getElementsByTagName('head')[0];
  headEl.appendChild(style);
  headEl.appendChild(otherStyle);
 }
 // Google Bar itself
 function jGoogleBar(map,options){ // constructor
  var z=this,
   searcher=z.ls=new LocalSearch;
  z.gmap=map;
  z.options=mergeObjs(options,defaultOptions);
  z.infowindow=new m.InfoWindow;
  z['build']();
  searcher['setCenterPoint'](map);
  if(z.options['resultSetSize']){
   searcher['setResultSetSize'](z.options['resultSetSize'])
  }
  searcher['setSearchCompleteCallback'](z,jGoogleBar.prototype['searchCompleteCallback']);
  if(typeof(z.options['buildCompleteCallback'])=='function'){
   z.options['buildCompleteCallback'].apply(z,[])
  }
 }
 jGoogleBar.prototype['build']=function(){ // build the html elements of the control
  var z=this,
   options=z.options,
   container=z['container']=createDiv('gmls',[
                                   z['innerContainer']=createDiv('gmls-app gmls-idle gmls-app-full-mode gmls-std-mode',[
                                             z['resultsDiv']=createDiv('gmls-results-popup gmls-results-popup-maximized',[
                                                                    createDiv('gmls-results-list',[
                                                                              createDiv('gmls-results-table',[
                                                                                        createEl('table','gmls-results-table',[
                                                                                                 z['resultsTable']=createEl('tbody')])
                                                                                                    ]),
                                                                              createDiv('gmls-results-controls',[
                                                                                        createEl('table','gmls-results-controls',[
                                                                                             createEl('tbody',null,[
                                                                                                 createEl('tr',null,[
                                                                                                          createEl('td','gmls-more-results gsc-results',[createDiv('gsc-cursor-box',[z['pageDiv']=createDiv('gsc-cursor')])]),
                                                                                                          createEl('td','gmls-prev-next'),
                                                                                                          createEl('td','gmls-clear-results',[createDiv('gmls-minimize-results gmls-control-button',[z.options['minimizeResultsString']],{
                                                                                                                                                         'onclick':function(){
                                                                                                                                                          z['minimizeResults']();
                                                                                                                                                         }
                                                                                                                                                        }),
                                                                                                                                              createDiv('gmls-maximize-results gmls-control-button',[z.options['maximizeResultsString']],{
                                                                                                                                                         'onclick':function(){
                                                                                                                                                          z['maximizeResults']();
                                                                                                                                                         }
                                                                                                                                                        }),
                                                                                                                                              createDiv('gmls-clear-results gmls-control-button',[z.options['clearResultsString']],{
                                                                                                                                                        'onclick':function(){
                                                                                                                                                          z.form['clearResults']();
                                                                                                                                                         }
                                                                                                                                                        })])
                                                                                                                     ])
                                                                                                               ])
                                                                                                 ])
                                                                                        ]),
                                                                              z['attributionDiv']=createDiv('gmls-attribution')
                                                                                          ])
                                                                           ]),
                                             z.formDiv=createDiv('gmls-search-form gmls-search-form-idle')
                                             ])
                                           ]),
   form=z.form=new SearchForm(0,z.formDiv,options.searchFormOptions),
   input=z['input']=form['input'],
   onfocuslistener=function(){
    z.formDiv.className=z.formDiv.className.replace(/\bgmls-search-form-idle\b/,'gmls-search-form-active');
   };
  if(options['resultList']){
   rmChildren(options['resultList']);
   options['resultList'].appendChild(z.formDiv);
   options['resultList'].appendChild(z['resultsDiv']);
  }
  form['setOnFocusListener'](z,onfocuslistener);
  form['setOnBlurListener'](z,onfocuslistener);
  form['setOnSubmitCallback'](z,jGoogleBar.prototype['execute']);
  form['setOnClearCallback'](z,jGoogleBar.prototype['clearResults']);
 };
 jGoogleBar.prototype['execute']=function(query){ // execute a search
  var z=this,
   searcher=z.ls,
   input=z['input'];
  z['clearResults']();
  if(typeof(query)=='string'){
   input['value']=query
  }
  searcher['execute'](input['value']);
  return false;
 };
 jGoogleBar.prototype['clearResults']=function(){ // clear the search results
  var z=this,
   table=z['resultsTable'],
   innerContainer=z['innerContainer'],
   searcher=z.ls,
   results=searcher['results'],
   pageDiv=z['pageDiv'],
   infowindow=z.infowindow;
  infowindow['close']();
  innerContainer.className=innerContainer.className.replace(/\bgmls-active\b/,'gmls-idle');
  if(!results){
   return
  }
  rmChildren(table);
  rmChildren(pageDiv);
  for(var i=0;i<results.length;i++){
   var result=results[i];
   result['marker']['setMap'](null);
  }
 };
 jGoogleBar.prototype['minimizeResults']=function(){
  var z=this,
   resultsDiv=z['resultsDiv'];
  resultsDiv.className=resultsDiv.className.replace(/\b(gmls-results-popup-)maximized\b/g,'$1minimized');
 };
 jGoogleBar.prototype['maximizeResults']=function(){
  var z=this,
   resultsDiv=z['resultsDiv'];
  resultsDiv.className=resultsDiv.className.replace(/\b(gmls-results-popup-)minimized\b/g,'$1maximized');
 };
 jGoogleBar.prototype['searchCompleteCallback']=function(){
  var z=this,
   searcher=z.ls,
   results=searcher['results'],
   cursor=searcher['cursor'],
   pageCell=z['pageDiv'],
   resultsTable=z['resultsTable'],
   attrib=searcher['getAttribution'](),
   infowindow=z.infowindow,
   map=z.gmap,
   options=z.options,
   viewport=searcher['resultViewport'],
   bounds=new m.LatLngBounds(new m.LatLng(parseFloat(viewport['sw']['lat']),parseFloat(viewport['sw']['lng'])),
                             new m.LatLng(parseFloat(viewport['ne']['lat']),parseFloat(viewport['ne']['lng']))),
   innerContainer=z['innerContainer'],
   resultClosure=function(result){
    return function(){
     jGoogleBar.prototype['selectResult'].apply(z,[result]);
    }
   },
   pageClosure=function(page){
    return function(){
     z['gotoPage'](page);
    }
   };
 if(!options['suppressCenterAndZoom']){
  map['fitBounds'](bounds);
 }
 for(var i=0;i<results.length;i++){
   var result=results[i],
    index=String.fromCharCode(65+i),
    html=result['listHtml']=createEl('tr',null,[createEl('td',null,[createDiv('gmls-result-list-item',[
                                                                     createDiv('gmls-result-list-item-key gmls-result-list-item-key-'+index+' gmls-result-list-item-key-local-'+index+' gmls-result-list-item-key-keymode',['&nbsp;']),
                                                                     createDiv('gs-title',[result['title']]),
                                                                     createDiv('gs-street',['&nbsp;-&nbsp;'+result['streetAddress']])
                                                                     ])])]),
    marker=result['marker']=new m.Marker({
                               'map' : options['showResultsMarkers'] ? map : null,
                               'position' : new m.LatLng(parseFloat(result['lat']), parseFloat(result['lng'])),
                               'title' : result['title'],
                               'icon' : typeof(options['icons'])=='string' ? options['icons'] : options['icons'][i],
                               'shadow' : options['shadow'],
                               'shape' : options['markerShape']
                              });
   var clickListener=resultClosure(result);
   m.event['addDomListener'](html,'click',clickListener);
   m.event['addListener'](marker,'click',clickListener);
   if(options['showResultsList']){
    resultsTable.appendChild(html);
   }
  }
  for(var i=0;cursor['pages'] && i<cursor['pages'].length;i++){
   var page=cursor['pages'][i];
   pageCell.appendChild(createDiv('gsc-cursor-page'+(i==cursor['currentPageIndex']?' gsc-cursor-current-page':''),[page.label],{
                                  'onclick' : pageClosure(i)
                                  }));
  }
  innerContainer.className=innerContainer.className.replace(/\bgmls-idle\b/,'gmls-active');
 };
 jGoogleBar.prototype['setResultSetSize']=function(size){
  this.ls['setResultSetSize'](size);
 };
 jGoogleBar.prototype['selectResult']=function(result){
  var z=this,
   searcher=z.ls,
   results=searcher['results'],
   map=z.gmap,
   infowindow=z.infowindow,
   marker=result['marker'];
  for(var i=0;i<searcher['results'].length;i++){
   var res=results[i],
    listItem=res['listHtml'].firstChild.firstChild;
   if(res===result){
    if(!listItem.className.match(/\bgmls-selected\b/)){
     listItem.className=listItem.className+=' gmls-selected';
    }
   }else{
    listItem.className=listItem.className.replace(/ gmls-selected/g,'');
   }
  }
  infowindow['close']();
  infowindow['setContent'](result['html']);
  infowindow['open'](map,marker);
 };
 jGoogleBar.prototype['gotoPage']=function(page){
  var z=this,
   searcher=z.ls;
  z['clearResults']();
  searcher['gotoPage'](page);
 };
 jGoogleBar.prototype['setQueryAddition']=function(addition){
  this.ls['setQueryAddition'](addition);
 }

 
 // Custom Local Search wrapper that supports GMaps v3
 function LocalSearch(){
  var z=this;
  z.options={
   'v':'1.0',
   'callback':'window.jeremy.gLocalSearch.callback',
   'context':LocalSearch['searchers'].length
  };
  LocalSearch['searchers'].push(z);
 }
 LocalSearch.prototype['setCenterPoint']=function(a){
  var z=this,
   options=z.options,
   b='function';
  if(typeis(a['lat'],b)&&typeis(a['lng'],b)&&typeis(a['toUrlValue'],b)){
   options['sll']=a['toUrlValue'](6)
  }else if(typeis(a['getCenter'],b)&&typeis(a['getBounds'],b)){
   options['sll']=function(){
    return a['getCenter']()['toUrlValue'](6);
   };
   options['gll']=function(){
    return a['getBounds']()['toUrlValue'](7).replace(/\./g,'');
   };
   options['sspn']=function(){
    return a['getBounds']()['toSpan']()['toUrlValue'](6);
   };
  }else if(typeis(a,'string')){
   options['sll']=a;
  }
 };
 LocalSearch.prototype['setResultSetSize']=function(a){
  this.options['rsz']=a;
 };
 LocalSearch.prototype['execute']=function(q,start){
  var z=this,
   options=z.options,
   argsStr=z.argsStr,
   qAdd=z.queryAddition;
  if(!typeis(start,'number') || !argsStr){
   argsStr=[];
   for(var i in options){
    argsStr.push([i,encodeURIComponent(typeis(options[i],'function')?options[i]():options[i])].join('='));
   }
  }
  if(start){
   argsStr.push(['start',encodeURIComponent(start)].join('='));
  }
  argsStr.push(['q',encodeURIComponent((q?q:z.currentQuery)+(qAdd?' '+qAdd:''))].join('='));
  if(q || (start && z.currentQuery)){
   z.currentQuery=q||z.currentQuery;
   var script=createScript(LocalSearch.baseUrl+argsStr.join('&'));
   document.getElementsByTagName('head')[0].appendChild(script);
  }
  z.argsStr=argsStr.slice(0,argsStr.length-(start?2:1));
 };
 LocalSearch.prototype['setSearchCompleteCallback']=function(context,method,args){
  this.searchCompleteCallback=createClosure(context,method,args)
 };
 LocalSearch.prototype['gotoPage']=function(page){
  var z=this,
   options=z.options,
   rsz=options['rsz'];
  if(!typeis(rsz,'number')){
   rsz=typeis(rsz,'string')&&rsz.match(/^large$/)?8:4
  }
  z.execute(z.currentQuery,rsz*page);
 };
 LocalSearch.prototype['RAWcallback']=function(response){
  var z=this,
   results=z['results']=response['results'];
  z['cursor']=response['cursor'];
  z['resultViewport']=response['viewport'];
  z.attribution=response['attribution'];
  for(var i=0;i<results.length;i++){
   z['createResultHtml'](results[i]);
  }
  if(typeis(z.searchCompleteCallback,'function')){
   z.searchCompleteCallback()
  }
 };
 LocalSearch.prototype['getAttribution']=function(){
  if(!this.attribution){
   return false;
  }
  return createDiv('gs-results-attribution',[this.attribution]);
 };
 LocalSearch.prototype['createResultHtml']=function(result){
  result['html']=createDiv('gs-result gs-localResult',[
                                                   createDiv('gs-title',[createEl('a','gs-title',[result['title']],{
                                                                                   href:result['url']
                                                                                  })]),
                                                   createDiv('gs-snippet',[result['snippet']]),
                                                   createDiv('gs-address',[
                                                                           createDiv('gs-street gs-addressLine',[result['streetAddress']]),
                                                                           createDiv('gs-city gs-addressLine',[result['city']+', '+result['region']]),
                                                                           createDiv('gs-country',[result['country']])
                                                                           ]),
                                                   createDiv('gs-phone',[(result['phoneNumbers'] && result['phoneNumbers'][0]) ? result['phoneNumbers'][0]['number'] : null]),
                                                   createDiv('gs-directions')
                                                   ])
 };
 LocalSearch.prototype['setQueryAddition']=function(addition){
  this.queryAddition=addition;
 };
 LocalSearch['searchers']=[];
 LocalSearch['callback']=function(context,response){
  LocalSearch['searchers'][context]['RAWcallback'](response)
 };
 LocalSearch.baseUrl='http://ajax.googleapis.com/ajax/services/search/local?';
 
 
 // SearchForm so we don't have to include google.search every time.
 function SearchForm(enableClear, parentEl, options){
  options = this.options = mergeObjs(options,{
                       'buttonText' : 'Search',
                       'hintString' : 'Search the map!'
                      });
  var z=this,
   input,
   form=z.form=createEl('form','gsc-search-box',[
                 createEl('table','gsc-search-box',[createEl('tbody',null,[
                           createEl('tr',null,[
                                     createEl('td','gsc-input',[input=z['input']=createEl('input','gsc-input',null,{
                                                                          'type' : 'text',
                                                                          'autocomplete' : 'off',
                                                                          'size' : 10,
                                                                          'name' : 'search',
                                                                          'title' : 'search',
                                                                          'value' : options['hintString'],
                                                                          'onfocus' : createClosure(z,SearchForm.prototype.toggleHint),
                                                                          'onblur' : createClosure(z,SearchForm.prototype.toggleHint)
                                                                         })]),
                                     createEl('td','gsc-search-button',[z.button=createEl('input','gsc-search-button',null,{
                                                                                  'type' : 'submit',
                                                                                  'value' : options['buttonText'],
                                                                                  'title' : 'search'
                                                                                 })]),
                                     z.clearButton=(enableClear ? createEl('td','gsc-clear-button',[createEl('div','gsc-clear-button',[' '],{
                                                                                                'title' : 'clear results',
                                                                                                'onclick' : function(){
                                                                                                              z.form['clearResults']()
                                                                                                             }
                                                                                               })]) : null)
                                    ])
                          ])],{
                          'cellspacing':0,
                          'cellpadding':0
                          }),
                 createEl('table','gsc-branding',[createEl('tbody',null,[
                           createEl('tr',null,[
                                     createEl('td','gsc-branding-user-defined'),
                                     createEl('td','gsc-branding-text',[createEl('div','gsc-branding-text',['powered by'])]),
                                     createEl('gsc-branding-img-noclear',[createEl('img','gsc-branding-img-noclear',null,{
                                                                                    'src' : 'http://www.google.com/uds/css/small-logo.png'
                                                                                   })])
                                    ])
                          ])])
                                          ],{
                 'accept-charset' : 'utf-8'
                 });
  if(parentEl){
   parentEl.appendChild(form)
  }
 }
 SearchForm.prototype['setOnSubmitCallback']=function(context, method, args){
  var form=this.form;
  if(!args){
   args=[]
  }
  args.splice(0,0,this);
  form.onsubmit=createClosure(context,method,args)
 };
 SearchForm.prototype['setOnClearCallback']=function(context,method,args){
  if(!args){
   args=[]
  }
  args.splice(0,0,this);
  this.onclear=createClosure(context,method,args)
 };
 SearchForm.prototype['execute']=function(query){
  var z=this,
   input=z['input'],
   form=z.form;
  input['value']=query;
  form['submit']();
 };
 SearchForm.prototype['setOnFocusListener']=function(context,method,args){
  this.onfocuslistener=createClosure(context,method,args)
 };
 SearchForm.prototype['setOnBlurListener']=function(context,method,args){
  this.onblurlistener=createClosure(context,method,args)
 }
 SearchForm.prototype.toggleHint=function(e){
  var z=this,
   input=z['input'],
   hintString = z.options['hintString'];
  if(!e){
   e=window.event
  }
  if(e['type']=='focus'){
   if(input['value']==hintString) input['value']='';
   if(z['onfocuslistener']) return z['onfocuslistener']()
  }else if(e['type']=='blur'){
   if(input['value']=='') input['value']=hintString;
   if(z['onblurlistener']) return z['onblurlistener']()
  }
 }
 SearchForm.prototype['clearResults']=function(){
  var z=this;
  z.form['reset']();
  if(z.onclear){
   return z.onclear();
  }
 }
 
 
 
 // utility functions
 function createEl(tag, className, children, attribs, styles){ // create an element with arbitrary tagName
  var el=document.createElement(tag||'div');
  if(className){
   el.className=className;
  }
  if(children){
   for(var i=0;i<children.length;i++){
    var child=children[i];
    if(typeof(child)=='string'||typeof(child)=='number'){
     el.innerHTML+=child;
    }else{
     try{
      el.appendChild(children[i])
     }catch(err){
      // well, we tried
     }
    }
   }
  }
  if(attribs){
   for(var i in attribs){
    if(i.match(/^on/) && typeis(attribs[i],'function')){
     el[i]=attribs[i]
    }else{
     el.setAttribute(i,attribs[i])
    }
   }
  }
  if(styles){
   for(var i in styles){
    el.style[i]=styles[i]
   }
  }
 return el
 }
 
 function createDiv(className, children, attribs, styles){ // wrapper for createEl to create divs.
  return createEl('div',className,children, attribs, styles)
 }
 
 function createScript(src){
  var el=createEl('script',null,null,{type:'text/javascript',src:src}),
   onload=function(){
    el.onload=null;
    el.parentNode.removeChild(el);
    delete(el)
   },
   onreadystatechange=function(){
    if(el.readyState=='ready'||el.readyState=='complete'){
    el.onreadystatechange=null;
    onload()
   }
  }
  return el
 }
 
 function createText(text){
  return document.createTextNode(text)
 }
 
 function createClosure(context,method,args){
  return function(){
   return method.apply(context,args?args:arguments)
  }
 }
 
 function rmChildren(el){
  while(el.firstChild){
  el.removeChild(el.firstChild)
  }
 }
 
 function mergeObjs(){ // merge two or more objects, giving precedence to first one
  var c={},
   d=arguments||[];
  for(var i=0;i<d.length;i++){
   var e=d[i];
   for(var j in e){
    if(typeof(c[j])=='undefined'){
     c[j]=e[j]
    }
   }
  }
  return c
 }
 
 function typeis(v, test){ // tests to see if v's type is test
  return typeof(v) == test
 }
 
 
 
 // export stuff
 if(!window['jeremy']){
  window['jeremy']={};
 }
 window['jeremy']['jGoogleBar']=jGoogleBar;
  window['jeremy']['jGoogleBar']['prototype']=jGoogleBar.prototype;
 window['jeremy']['gLocalSearch']=LocalSearch;
  window['jeremy']['gLocalSearch']['prototype']=LocalSearch.prototype;
 window['jeremy']['SearchForm']=SearchForm;
  window['jeremy']['SearchForm']['prototype']=SearchForm.prototype;
})()