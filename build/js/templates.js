module.exports = function anonymous(locals,attrs,escape,rethrow,merge){attrs=attrs || jade.attrs;escape=escape || jade.escape;rethrow=rethrow || jade.rethrow;merge=merge || jade.merge;var buf=[];with (locals ||{}){var interp;var __indent=[];buf.push('<!DOCTYPE html>\n<html ng-app="App">\n <head>\n <meta charset="utf-8">\n <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">\n <title>Dashboard Demo</title>\n <link rel="favicon.ico" href="favicon.ico">\n <link rel="stylesheet" href="css/app.css">\n <script src="js/vendor.js"></script>\n <script src="js/app.js"></script>\n </head>\n <body>\n <div ng-view class="container-fluid"></div>\n </body>\n</html>')}return buf.join("")};module.exports = function anonymous(locals,attrs,escape,rethrow,merge){attrs=attrs || jade.attrs;escape=escape || jade.escape;rethrow=rethrow || jade.rethrow;merge=merge || jade.merge;var buf=[];with (locals ||{}){var interp;var __indent=[];buf.push('\n<div class="row-fluid">\n <div id="header" class="row-fluid">\n <div class="span12 centered">\n <h3>Navigation</h3>\n <div class="navbar">\n <div class="navbar-inner">\n <ul class="nav">\n <li ng-class="all_categories"><a ng-click="toggleAllCategories()">All</a></li>\n <li ng-repeat="(category_name,category) in categories" ng-class="category.class"><a ng-click="toggleCategory(category)">{{ category_name}}</a></li>\n </ul>\n </div>\n </div>\n </div>\n </div>\n <div id="content" class="row-fluid">\n <div class="span2">\n <h4>Show/hide</h4>\n <label ng-repeat="(name,cell) in grid" class="checkbox">\n <input type="checkbox" ng-model="cell.active"/>{{ name}}<br/>{{ cell.repr()}}\n </label>\n </div>\n <div class="span10">\n <div id="graphs">\n <div ng-repeat="(name,values) in grid" ng-show="values.active">\n <pk-plot plot="values" cats="categories" itm="data" click="scrollTo(id)" id="{{ values.id}}" class="plot_cell"></pk-plot>\n </div>\n </div>\n </div>\n </div>\n <div id="footer" class="row-fluid">\n <div class="span12">\n <table class="table">\n <thead>\n <th>ID</th>\n <th ng-repeat="key in position_keys">{{key}}</th>\n <th>Category</th>\n </thead>\n <tbody>\n <tr ng-repeat="item in data" id="row_{{item.id}}" ng-show="activeCategory(item.category)">\n <td>{{ item["id"]}}</td>\n <td ng-repeat="key in position_keys">{{ item[key]}}</td>\n <td>{{ item.category}}</td>\n </tr>\n </tbody>\n </table>\n </div>\n </div>\n</div>')}return buf.join("")};