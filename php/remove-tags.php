<?php


$text = file_get_contents('tags.html');

$result = sanitize_html_text_only($text);

file_put_contents('tags-sanitized.html', $result);


function sanitize_html_keep_tags(string $html): string {
    libxml_use_internal_errors(true);

    $doc = new DOMDocument();
    $doc->loadHTML('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' . $html);
    $xpath = new DOMXPath($doc);

    // Remove unwanted tags
    foreach (['img', 'svg', 'style', 'script', 'figure'] as $tag) {
        foreach ($xpath->query("//{$tag}") as $node) {
            $node->parentNode->removeChild($node);
        }
    }

    // Remove <a> entirely but keep their text content
    foreach ($xpath->query("//a") as $a) {
        $text = $doc->createTextNode($a->textContent);
        $a->parentNode->replaceChild($text, $a);
    }

    // Strip all attributes from remaining tags
    foreach ($xpath->query('//*') as $el) {
        while ($el->attributes->length > 0) {
            $el->removeAttributeNode($el->attributes->item(0));
        }
    }

    //remove empty tags
    foreach ($xpath->query('//*') as $el) {
        if (trim($el->textContent) === '' && !$el->hasChildNodes()) {
            $el->parentNode->removeChild($el);
        }
    }

    $body = $doc->getElementsByTagName('body')->item(0);



    return trim($doc->saveHTML($body));
}

function sanitize_html_text_only(string $html): string
{
    libxml_use_internal_errors(true);

    $doc = new DOMDocument();
    $doc->loadHTML('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'.$html);

    // Remove images, svg, style, script, links
    $remove_tags = ['img', 'svg', 'style', 'script', 'a'];
    foreach ($remove_tags as $tag) {
        $elements = $doc->getElementsByTagName($tag);
        for ($i = $elements->length - 1; $i >= 0; $i--) {
            $el = $elements->item($i);
            if ($tag === 'a') {
                // Keep anchor text
                $el->parentNode->replaceChild($doc->createTextNode($el->textContent), $el);
            } else {
                $el->parentNode->removeChild($el);
            }
        }
    }

    // Extract text only
    return trim($doc->textContent);
}

