<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="/rss/channel/title"/></title>
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&amp;family=Source+Serif+4:ital,wght@0,300;0,400;1,300&amp;display=swap');

          *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

          :root {
            --ink:     #1a1410;
            --muted:   #6b5e52;
            --rule:    #d4c9bc;
            --cream:   #faf7f2;
            --accent:  #b5451b;
            --card-bg: #ffffff;
          }

          body {
            background: var(--cream);
            color: var(--ink);
            font-family: 'Source Serif 4', Georgia, serif;
            font-weight: 300;
            line-height: 1.7;
            min-height: 100vh;
          }

          /* ── masthead ── */
          header {
            background: var(--ink);
            color: var(--cream);
            padding: 3rem 2rem 2.5rem;
            text-align: center;
            border-bottom: 4px solid var(--accent);
          }

          .feed-tag {
            display: inline-block;
            font-family: 'Source Serif 4', serif;
            font-size: .65rem;
            font-weight: 400;
            letter-spacing: .2em;
            text-transform: uppercase;
            color: var(--accent);
            border: 1px solid var(--accent);
            padding: .25rem .7rem;
            margin-bottom: 1.2rem;
          }

          header h1 {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: clamp(2rem, 5vw, 3.5rem);
            font-weight: 700;
            line-height: 1.1;
            letter-spacing: -.01em;
            margin-bottom: .75rem;
          }

          header p.description {
            font-style: italic;
            font-size: 1.05rem;
            color: #c9bfb4;
            max-width: 60ch;
            margin: 0 auto .75rem;
          }

          header .meta {
            font-size: .8rem;
            color: #8a7d72;
            letter-spacing: .05em;
          }

          header .meta a {
            color: var(--accent);
            text-decoration: none;
          }

          header .meta a:hover { text-decoration: underline; }

          /* ── layout ── */
          main {
            max-width: 860px;
            margin: 0 auto;
            padding: 3rem 1.5rem 5rem;
          }

          .section-rule {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 2.5rem;
            color: var(--muted);
            font-size: .7rem;
            letter-spacing: .18em;
            text-transform: uppercase;
          }

          .section-rule::before,
          .section-rule::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--rule);
          }

          /* ── article cards ── */
          .item {
            background: var(--card-bg);
            border: 1px solid var(--rule);
            border-top: 3px solid var(--ink);
            padding: 2rem 2.25rem;
            margin-bottom: 1.75rem;
            transition: box-shadow .2s ease, transform .2s ease;
          }

          .item:hover {
            box-shadow: 4px 4px 0 var(--rule);
            transform: translate(-2px, -2px);
          }

          .item-date {
            font-size: .72rem;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: var(--muted);
            margin-bottom: .6rem;
          }

          .item h2 {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 1.45rem;
            font-weight: 700;
            line-height: 1.25;
            margin-bottom: .9rem;
          }

          .item h2 a {
            color: var(--ink);
            text-decoration: none;
          }

          .item h2 a:hover {
            color: var(--accent);
          }

          .item p.summary {
            font-size: .97rem;
            color: #3d342c;
            line-height: 1.75;
            margin-bottom: 1.25rem;
            /* strip any embedded HTML tags from description */
          }

          .read-more {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            font-size: .8rem;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: var(--accent);
            text-decoration: none;
            font-weight: 400;
            border-bottom: 1px solid transparent;
            transition: border-color .15s;
          }

          .read-more:hover { border-color: var(--accent); }
          .read-more::after { content: '→'; }

          /* ── footer ── */
          footer {
            text-align: center;
            padding: 2rem;
            font-size: .78rem;
            color: var(--muted);
            border-top: 1px solid var(--rule);
          }

          footer a { color: var(--muted); }

          @media (max-width: 540px) {
            header { padding: 2rem 1.25rem; }
            .item  { padding: 1.5rem 1.25rem; }
          }
        </style>
      </head>
      <body>

        <header>
          <div class="feed-tag">RSS Feed</div>
          <h1><xsl:value-of select="/rss/channel/title"/></h1>
          <xsl:if test="/rss/channel/description">
            <p class="description"><xsl:value-of select="/rss/channel/description"/></p>
          </xsl:if>
          <p class="meta">
            <xsl:if test="/rss/channel/link">
              <a href="{/rss/channel/link}" target="_blank" rel="noopener">
                <xsl:value-of select="/rss/channel/link"/>
              </a>
            </xsl:if>
          </p>
        </header>

        <main>
          <div class="section-rule">Latest Posts</div>

          <xsl:for-each select="/rss/channel/item">
            <article class="item">
              <xsl:if test="pubDate">
                <p class="item-date"><xsl:value-of select="pubDate"/></p>
              </xsl:if>

              <h2>
                <xsl:choose>
                  <xsl:when test="link">
                    <a href="{link}" target="_blank" rel="noopener">
                      <xsl:value-of select="title"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="title"/>
                  </xsl:otherwise>
                </xsl:choose>
              </h2>

              <xsl:if test="description">
                <p class="summary"><xsl:value-of select="description"/></p>
              </xsl:if>

              <xsl:if test="link">
                <a class="read-more" href="{link}" target="_blank" rel="noopener">Read article</a>
              </xsl:if>
            </article>
          </xsl:for-each>
        </main>

        <footer>
          This feed is rendered with an XSL stylesheet.
          Subscribe by copying the feed URL into your RSS reader.
        </footer>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
