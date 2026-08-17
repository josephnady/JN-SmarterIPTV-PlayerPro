package com.jnsmarter.iptvbackend.parsing;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.StringReader;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class XmltvParser {

    private static final Pattern TIME_PATTERN =
            Pattern.compile("^(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})(\\d{2})\\s*([+-]\\d{4})?");

    private XmltvParser() {
    }

    /** Best-effort parse — malformed or missing EPG data returns an empty list rather than throwing. */
    public static List<Programme> parse(String xml) {
        List<Programme> result = new ArrayList<>();
        if (xml == null || xml.isBlank()) return result;

        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            try {
                dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            } catch (Exception ignored) {
                // Not all parser implementations support this feature — safe to skip.
            }
            dbf.setExpandEntityReferences(false);
            DocumentBuilder builder = dbf.newDocumentBuilder();
            Document doc = builder.parse(new InputSource(new StringReader(xml)));

            NodeList nodes = doc.getElementsByTagName("programme");
            for (int i = 0; i < nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                String channelId = el.getAttribute("channel");
                if (channelId == null || channelId.isBlank()) continue;

                Long start = parseTime(el.getAttribute("start"));
                if (start == null) continue;
                Long stop = parseTime(el.getAttribute("stop"));

                String title = textOf(el, "title");
                String desc = textOf(el, "desc");

                result.add(new Programme(channelId, start, stop,
                        title == null || title.isBlank() ? "Untitled" : title,
                        desc == null ? "" : desc));
            }
        } catch (Exception e) {
            // Return whatever we parsed so far (likely empty) rather than failing the request.
        }
        return result;
    }

    private static String textOf(Element parent, String tag) {
        NodeList list = parent.getElementsByTagName(tag);
        if (list.getLength() == 0) return null;
        return list.item(0).getTextContent();
    }

    private static Long parseTime(String s) {
        if (s == null || s.isBlank()) return null;
        Matcher m = TIME_PATTERN.matcher(s.trim());
        if (!m.find()) return null;

        int year = Integer.parseInt(m.group(1));
        int month = Integer.parseInt(m.group(2));
        int day = Integer.parseInt(m.group(3));
        int hour = Integer.parseInt(m.group(4));
        int minute = Integer.parseInt(m.group(5));
        int second = Integer.parseInt(m.group(6));
        String offset = m.group(7);

        ZoneOffset zone = ZoneOffset.UTC;
        if (offset != null) {
            int sign = offset.startsWith("-") ? -1 : 1;
            int oh = Integer.parseInt(offset.substring(1, 3));
            int om = Integer.parseInt(offset.substring(3, 5));
            zone = ZoneOffset.ofTotalSeconds(sign * (oh * 3600 + om * 60));
        }

        ZonedDateTime zdt = ZonedDateTime.of(year, month, day, hour, minute, second, 0, zone);
        return zdt.toInstant().toEpochMilli();
    }
}
