library angular2.test.router.integration.auxiliary_route_spec;

import "package:angular2/testing_internal.dart"
    show
        RootTestComponent,
        AsyncTestCompleter,
        TestComponentBuilder,
        beforeEach,
        ddescribe,
        xdescribe,
        describe,
        el,
        expect,
        iit,
        inject,
        beforeEachProviders,
        it,
        xit;
import "package:angular2/core.dart" show provide, Component, Injector, Inject;
import "package:angular2/router.dart"
    show Router, ROUTER_DIRECTIVES, RouteParams, RouteData, Location;
import "package:angular2/src/router/route_config_decorator.dart"
    show RouteConfig, Route, AuxRoute, Redirect;
import "util.dart"
    show TEST_ROUTER_PROVIDERS, RootCmp, compile, clickOnElement, getHref;

getLinkElement(RootTestComponent rtc) {
  return rtc.debugElement.componentViewChildren[0].nativeElement;
}

var cmpInstanceCount;
var childCmpInstanceCount;
main() {
  describe("auxiliary routes", () {
    TestComponentBuilder tcb;
    RootTestComponent fixture;
    var rtr;
    beforeEachProviders(() => TEST_ROUTER_PROVIDERS);
    beforeEach(inject([TestComponentBuilder, Router], (tcBuilder, router) {
      tcb = tcBuilder;
      rtr = router;
      childCmpInstanceCount = 0;
      cmpInstanceCount = 0;
    }));
    it(
        "should recognize and navigate from the URL",
        inject([AsyncTestCompleter], (async) {
          compile(tcb,
                  '''main {<router-outlet></router-outlet>} | aux {<router-outlet name="modal"></router-outlet>}''')
              .then((rtc) {
            fixture = rtc;
          })
              .then((_) => rtr.config([
                    new Route(
                        path: "/hello", component: HelloCmp, name: "Hello"),
                    new AuxRoute(
                        path: "/modal", component: ModalCmp, name: "Aux")
                  ]))
              .then((_) => rtr.navigateByUrl("/hello(modal)"))
              .then((_) {
            fixture.detectChanges();
            expect(fixture.debugElement.nativeElement)
                .toHaveText("main {hello} | aux {modal}");
            async.done();
          });
        }));
    it(
        "should navigate via the link DSL",
        inject([AsyncTestCompleter], (async) {
          compile(tcb,
                  '''main {<router-outlet></router-outlet>} | aux {<router-outlet name="modal"></router-outlet>}''')
              .then((rtc) {
            fixture = rtc;
          })
              .then((_) => rtr.config([
                    new Route(
                        path: "/hello", component: HelloCmp, name: "Hello"),
                    new AuxRoute(
                        path: "/modal", component: ModalCmp, name: "Modal")
                  ]))
              .then((_) => rtr.navigate([
                    "/Hello",
                    ["Modal"]
                  ]))
              .then((_) {
            fixture.detectChanges();
            expect(fixture.debugElement.nativeElement)
                .toHaveText("main {hello} | aux {modal}");
            async.done();
          });
        }));
    it(
        "should generate a link URL",
        inject([AsyncTestCompleter], (async) {
          compile(tcb,
                  '''<a [router-link]="[\'/Hello\', [\'Modal\']]">open modal</a> | main {<router-outlet></router-outlet>} | aux {<router-outlet name="modal"></router-outlet>}''')
              .then((rtc) {
            fixture = rtc;
          })
              .then((_) => rtr.config([
                    new Route(
                        path: "/hello", component: HelloCmp, name: "Hello"),
                    new AuxRoute(
                        path: "/modal", component: ModalCmp, name: "Modal")
                  ]))
              .then((_) {
            fixture.detectChanges();
            expect(getHref(getLinkElement(fixture))).toEqual("/hello(modal)");
            async.done();
          });
        }));
    it(
        "should navigate from a link click",
        inject([AsyncTestCompleter, Location], (async, location) {
          compile(tcb,
                  '''<a [router-link]="[\'/Hello\', [\'Modal\']]">open modal</a> | main {<router-outlet></router-outlet>} | aux {<router-outlet name="modal"></router-outlet>}''')
              .then((rtc) {
            fixture = rtc;
          })
              .then((_) => rtr.config([
                    new Route(
                        path: "/hello", component: HelloCmp, name: "Hello"),
                    new AuxRoute(
                        path: "/modal", component: ModalCmp, name: "Modal")
                  ]))
              .then((_) {
            fixture.detectChanges();
            expect(fixture.debugElement.nativeElement)
                .toHaveText("open modal | main {} | aux {}");
            rtr.subscribe((_) {
              fixture.detectChanges();
              expect(fixture.debugElement.nativeElement)
                  .toHaveText("open modal | main {hello} | aux {modal}");
              expect(location.urlChanges).toEqual(["/hello(modal)"]);
              async.done();
            });
            clickOnElement(getLinkElement(fixture));
          });
        }));
  });
}

@Component(selector: "hello-cmp", template: '''{{greeting}}''')
class HelloCmp {
  String greeting;
  HelloCmp() {
    this.greeting = "hello";
  }
}

@Component(selector: "modal-cmp", template: '''modal''')
class ModalCmp {}

@Component(
    selector: "aux-cmp",
    template: "main {<router-outlet></router-outlet>} | " +
        "aux {<router-outlet name=\"modal\"></router-outlet>}",
    directives: const [ROUTER_DIRECTIVES])
@RouteConfig(const [
  const Route(path: "/hello", component: HelloCmp, name: "Hello"),
  const AuxRoute(path: "/modal", component: ModalCmp, name: "Aux")
])
class AuxCmp {}