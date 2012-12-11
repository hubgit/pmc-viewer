window.URL = window.URL || window.webkitURL;

var app = {
	/* tranform image URLs to PMC URLs */
	setImageURL: function(index, node) {
		var node = $(node);
		var url = "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC" + app.id + "/bin/" + node.attr("src") + ".jpg";
		node.attr("src", url);
	},

	/* add popover to references */
	addReferencePopovers: function() {
		$(".xref[href^=#]")
			.filter(function() {
				var id = $(this).attr("href").replace(/\./g, "\\.");
				return $(id).hasClass("ref");
			})
			.click(function() {
				//$(".popover").remove();
				return false;
			})
			.popover({
				html: true,
				title: function() {
					var id = $(this).attr("href").replace(/\./g, "\\.");
					return $(id).find(".article-title").clone();
				},
				trigger: "click",
				placement: function (tip, element) {
					var win = $(window);

					var width = 400;
					var height = 200;

			        var offset = $(element).offset();

			        var top = offset.top - win.scrollTop();
			        var bottom = win.scrollTop() + win.height() - offset.top;
			        var left = offset.left - win.scrollLeft();
			        var right = win.width() - (offset.left + $(element).width());

			        if (left < width / 2) {
			        	return "right";
			        }

			        if (left < width) {
			        	if (top < height) {
			        		return "bottom";
			        	}
			        	if (bottom < height) {
			        		return "top";
			        	}
			        	return "right";
			        }

			        if (right < width / 2) {
			        	return "left";
			        }

			        if (right < width) {
			        	if (top < height) {
			        		return "bottom";
			        	}
			        	if (bottom < height) {
			        		return "top";
			        	}
			        	return "left";
			        }

			        if (bottom < height) {
			        	return "top";
			        }

			        return "bottom";
				},
				content: function() {
					var id = $(this).attr("href").replace(/\./g, "\\.");
					return $(id).html();
				}
			});
	},

	augmentDocument: function(article) {
		//console.log("Augmenting");

		var published = article.find("header time");
		published.text(moment(published.text()).format("MMMM Do, YYYY"));

		article.find("[src]").each(app.setImageURL);

		$("<div/>", { id: "links" }).hide().appendTo("body");

		/* build reference sources */
		article.find(".label").each(function() {
			var node = $(this);

			var id = node.closest("[id]").attr("id");

			var i = 0;
			var links = [];

			article.find("a[href='#" + id + "']").each(function() {
				var refid = "xref-" + id + "-" + i++;

				$(this).attr("id", refid);

				var link = $("<a/>", { href: "#" + refid })
					.text(i)
					.addClass("link");

				links.push(link);
			});

			node.data({ links: links, id: id });
		});

		/* show reference sources when clicked */
		article.on("click", ".badge", function(event) {
			var node = $(this);
			var links = $("#links");

			if (node.data("id") === links.data("id")) {
				links.hide();
				return;
			}

			var position = node.offset();

			links
				.data("id", node.data("id"))
				.html(node.data("links"))
				.css({ left: position.left + node.width() + 10, top: position.top - 6 })
				.show();
		});

		/* add link targets to headers */
		article.find(":header").each(function() {
			var node = $(this);

			/* normalise the header text for use as a URL fragment */
			var name = node.text().toLowerCase().replace(/\W/g, '-');

			$("<a/>")
				.addClass("anchor")
				.attr("href", "#" + name)
				.attr("name", name)
				.prependTo(node)
				.append('<span class="mini-icon mini-icon-link"></span>');
		});

		article.find("img[position=float],figure[position=float] img").addClass("floating-image");

		article.find("footer .ref-list .ref .label").removeClass("label").addClass("badge").wrap("<span class='ref-label'/>");
	},

	transformXML: function(xsl, dom) {
		/* import the XSL stylesheet */
		var processor = new XSLTProcessor();
		processor.importStylesheet(xsl);

		/* transform the XML document to an XHTML fragment */
		var fragment = processor.transformToFragment(dom, document);

		var node = document.createElement("div");
		node.appendChild(fragment);
		return node.firstChild;
	},

	/* convert the article xml to HTML and append it to the document */
	transformDocument: function(xmlXHR, xslXHR){
		var html = app.transformXML(xslXHR[0], xmlXHR[0]);

		var article = $(html);

		/* fix up the document before inserting it */
		app.augmentDocument(article);

		/* insert the HTML fragment into the document */
		article.appendTo("body");

		app.addReferencePopovers();

		//console.log("Inserted");

		return false; // break
	},

	handleURL: function() {
		/* extract the PMC ID from the path */
		var matches = window.location.pathname.match(/\/(\d+)\/?$/);

		if (!matches) {
			var matches = window.location.hash.match(/#(\d+)\/?$/);
		}

		if (!matches) {
			return;
		}

		app.id = matches[1];

		/* fetch Gist and XSL */
		var fetchXML = $.ajax({
			url: "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=" + app.id,
			dataType: "xml"
		});

		var fetchXSL = $.ajax({
			url: "article.xsl",
			dataType: "xml"
		});

		$.when(fetchXML, fetchXSL).done(app.transformDocument);
	}
};

$(app.handleURL);
