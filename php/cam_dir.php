<?php
function fetch_page($page) {
    $url = "https://directory.kam.co.ke/?mylisting-ajax=1&action=get_listings&security=dcaad98e19&form_data%5Bpage%5D=0&form_data%5Bpreserve_page%5D=false&form_data%5Bpage%5D=$page&form_data%5Bsearch_keywords%5D=&form_data%5Bcategory%5D=metal-allied&form_data%5Bsearch_location%5D=&form_data%5Blat%5D=false&form_data%5Blng%5D=false&form_data%5Bproximity%5D=20&form_data%5Bregion%5D=&form_data%5Btags%5D=&form_data%5Bsort%5D=latest&listing_type=place&listing_wrap=col-md-6%20col-sm-6%20grid-item&proximity_units=mi";

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'accept: application/json, text/javascript, */*; q=0.01',
        'accept-language: en-US,en;q=0.9',
        'priority: u=1, i',
        'referer: https://directory.kam.co.ke/explore/?type=place&category=metal-allied&sort=latest',
        'sec-ch-ua: "Google Chrome";v="141", "Not?A_Brand";v="8", "Chromium";v="141"',
        'sec-ch-ua-mobile: ?0',
        'sec-ch-ua-platform: "Windows"',
        'sec-fetch-dest: empty',
        'sec-fetch-mode: cors',
        'sec-fetch-site: same-origin',
        'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36',
        'x-requested-with: XMLHttpRequest'
    ]);
    curl_setopt($ch, CURLOPT_COOKIE, '<cookie-name>=<cookie-value>');

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code == 200) {
        return json_decode($response, true);
    } else {
        return false;
    }
}

function parse_listings($html) {
    $listings = [];
    $doc = new DOMDocument();
    @$doc->loadHTML($html); 
    $xpath = new DOMXPath($doc);

    $items = $xpath->query("//div[contains(@class, 'lf-item-container')]");
    foreach ($items as $item) {
        $listing = [];

        $title = $xpath->query(".//h4[contains(@class, 'listing-preview-title')]", $item);
        $listing['title'] = $title->length > 0 ? trim($title->item(0)->nodeValue) : '';

        $contact = $xpath->query(".//ul[contains(@class, 'lf-contact')]//li", $item);
        $listing['contact'] = $contact->length > 0 ? trim($contact->item(0)->nodeValue) : '';

        $listings[] = $listing;
    }

    return $listings;
}

$all_listings = [];
$max_pages = 5; // have to change this manually or it will break
$output_file = 'listings_consultancy.json';

for ($page = 0; $page < $max_pages; $page++) {
    echo "Fetching page " . ($page + 1) . " of $max_pages...\n";
    $data = fetch_page($page);

    if ($data && isset($data['html'])) {
        $listings = parse_listings($data['html']);
        $all_listings = array_merge($all_listings, $listings);
    } else {
        echo "Failed to fetch page " . ($page + 1) . "\n";
    }

    
    sleep(1);
}

file_put_contents($output_file, json_encode($all_listings, JSON_PRETTY_PRINT));
echo "Data saved to $output_file\n";
