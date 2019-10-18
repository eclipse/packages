---
title: Questions and answers
layout: page
lead: You have questions? We might have some answers!
---

<section>
<h2>Questions</h2>

<ul>
{% for question in site.questions %}
    <li>
        <a href="#{{ question.title | slugify }}">
            {{- question.title | escape -}}
        </a>
    </li>
{% endfor %}
</ul>
</section>

<h2>Answers</h2>

{% for question in site.questions %}
<section>
    <h3 id="{{ question.title | slugify }}">{{- question.title | escape }}</h3>
    {{- question.content | markdownify }}
</section>
{% endfor %}

