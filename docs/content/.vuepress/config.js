module.exports = {

    base: "/metabox/",

    themeConfig: {
        
        // does not work under Docker container, hmm
        //lastUpdated: 'Last Updated',

        repo: 'SubPointSolutions/metabox',
        //repoLabel: 'Contribute!',
        docsRepo: 'SubPointSolutions/metabox',
        docsDir: 'docs/content',
        docsBranch: 'origin/0.2.3-dev',
        editLinks: true,
        editLinkText: 'Edit this page',

        nav: [
            { text: 'Home', link: '/' }
           
        ],

        sidebar: [
            '/' ,
            '/metabox-installation',
            '/metabox-guides',
            '/metabox-cli',
            '/metabox-ci',
            '/metabox-documents',
            '/metabox-tech-design',
            '/metabox-other',
            '/metabox-known-issues'
        ]
    }
  }