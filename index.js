new Vue({
    el: '#app',

    data: {
        title: '',
        description: '',
        code: '',
        name: '',
        date: '',
        //the array of all the snippets   
        snippets: [],
    },
    mounted() {
        this.GetData();
    },
    methods: {
        GetData() {
            fetch("https://munenepeter.github.io/scripts/snippets.json")
                .then(response => response.json())
                .then((data) => {
                    this.snippets = data;
                });
        },
        AddSnippet() {

            this.snippets.push({
                id: Date.now(),
                title: this.title,
                description: this.description,
                code: this.code,
                name: this.name
            });
            // fetch("https://munenepeter.github.io/php-snippets/snippets.json", {
            //     body: this.snippets,
            //     method: "POST",
            //     headers: {
            //         "Content-Type": "application/json",
            //     },
            // }).then(this.GetData());
            //remove the values in form
            this.title = "";
            this.description = "";
            this.code = "";
            this.name = "";
        }
    }

});