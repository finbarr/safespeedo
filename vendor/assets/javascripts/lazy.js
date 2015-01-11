(function() {
  var l = window._lazy = {
    loaded: {},
    lazy: {}
  };

  function lazystore(name, definition) {
    l.lazy[name] = definition;
  }

  function loadDependency(dependencyName) {
    if (l.loaded[dependencyName]) {
      return l.loaded[dependencyName];
    }
    console.log("Loading " + dependencyName);
    l.loaded[dependencyName] = l.lazy[dependencyName]();
    delete l.lazy[dependencyName];
    return l.loaded[dependencyName];
  }

  function loadDependencies(dependencyNames) {
    var deps = [];
    for(var i = 0; i < dependencyNames.length; i++) {
      deps.push(loadDependency(dependencyNames[i]));
    }
    return deps;
  }

  window.lazyload = function(dependencyNames, callback) {
    if(typeof dependencyNames == "object") {
      // many dependencies
      return callback.apply(callback, loadDependencies(dependencyNames));
    } else {
      // one dependency
      return callback.call(callback, loadDependency(dependencyNames));
    }
  }

  window.lazydefine = function(name, dependencyNames, definition) {
    if(typeof dependencyNames == "function") {
      // no dependencies
      lazystore(name, dependencyNames);
    } else {
      // one or more dependencies
      lazystore(name, function() {
        return definition.apply(definition, loadDependencies(dependencyNames));
      });
    }
  }
})();
